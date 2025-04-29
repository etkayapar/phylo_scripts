"""
Extract found gene sequences by newer BUSCO versions

Usage: python3 find_buscos.py <BUSCO_RESULTS_DIR> <GENE_OUTPUT_DIR> <MIN_TAXON_THRESHOLD>
Positional arguments:
    BUSCO_RESULTS_DIR: Path to the parent directory under which all the per-sample BUSCO output directories exist
    GENE_OUTPUT_DIR: Name of directory to be created that will have the resulting per-gene fasta files
    MIN_TAXON_THRESHOLD: Minimum taxon occupancy threshold for a gene to be included in the output. (e.g. 70 would mean 70%)

N.B! Change the value of BUSCO_DATASET variable inside main() to suit your needs. Right now it is hard-coded to look for
results from BUSCO runs with the Lepidoptera dataset. This value should only include the taxonomic level name. For example,
if you want to change it to hemiptera, then this value should be "hemiptera" and not "run_hemiptera_odb10" which is the actual
folder name under which your results will be.

"""
import os
import glob
import tarfile
import shutil
from sys import argv
from multiprocessing import Pool


def detect_busco_mode(startdir):
    species_list = [ os.path.basename(f.path) for f in os.scandir(startdir) if (f.is_dir() and "busco_downloads" not in f.path and os.path.basename(f.path)[0] != ".")] 
    retval = {}
    for species in species_list:
        try:
            log_fname = [x for x in glob.glob(startdir+"/"+species+"/short_summary*.txt")][0]
        except IndexError:
            ## The 'species' folder is not a busco_output.
            continue
        with open(log_fname) as logF:
            for l in logF:
                if l.startswith("# BUSCO was run in mode:"):
                    tmpval = l.strip().split(":")[1].lstrip()
                    if "_" in tmpval:
                        tmpval = tmpval.split("_")[1]
                    retval[species] = tmpval
    return retval


def parse_table_genome(fname):
    complete_buscos = list()
    with open(fname) as table:
        for l in table:
            if l.startswith("#"):
                continue
            l = l.strip().split()
            if l[1] != "Complete":
                continue
            busco = l[0]
            complete_buscos.append(busco)
    return complete_buscos

def parse_table_ids(fname):
    '''
    Parse one of the tables at random so that there will be full list
    BUSCOS analysed in the memory for later use
    '''
    ids = set()
    with open(fname) as table:
        for l in table:
            if l.startswith("#"):
                continue
            l = l.strip().split()
            busco = l[0]
            ids.add(busco)

    ids = list(ids)
    ids.sort()
    return ids


def process_sample(sample_name, base_dir, busco_dataset):
    '''
    get complete buscos list from a single sample
    '''

    run_folder = f"run_{busco_dataset}_odb10"
    busco_table_fname = os.path.join(base_dir, sample_name, run_folder, "full_table.tsv")
    complete_buscos = parse_table_genome(busco_table_fname)

    return complete_buscos


def process_all_samples(samples_list, base_dir, busco_dataset, min_tax_percent=90):

    '''
    call `process_sample()` for all samples and get a list of buscos that meet
    some thresholds
    '''

    busco_count_dict = dict()

    for sample in samples_list:
        this_sample_buscos = process_sample(sample, base_dir, busco_dataset)
        for busco in this_sample_buscos:
            if busco in busco_count_dict:
                busco_count_dict[busco] += 1
            else:
                busco_count_dict[busco] = 1

    n_tax = len(samples_list)
    buscos_to_keep = [
        x
        for x in busco_count_dict
        if busco_count_dict[x]/n_tax * 100 >= min_tax_percent
    ]

    return buscos_to_keep

def parse_fasta_dirty(fname, sample_name, tarfile=False):
    '''
    handles both file_paths or already opened file objects
    we are counting on the fact that each FASTA file will only have a single
    FASTA entry in it. no need for fancy checks (for now)
    '''
    
    header=f">{sample_name}"
    seq = []
    if tarfile:
        f = fname
        for l in f:
            l = l.decode()
            if l.startswith(">"):
                continue
            seq.append(l.strip())
    else:
        f = open(fname, "r")
        for l in f:
            if l.startswith(">"):
                continue
            seq.append(l.strip())


    seq = "".join(seq)
    seq = "\n".join([header, seq])

    if not tarfile:
        f.close()

    return seq

def collect_buscos_all_samples(busco_list, samples_list, base_dir, busco_dataset):
    busco_dataset=f"run_{busco_dataset}_odb10"
    cleanupafter = False
    busco_dict = {busco: {'fna': list(), 'faa': list()} for busco in busco_list}

    for sample in samples_list:
        base_name = os.path.join(base_dir, sample, busco_dataset, 'busco_sequences', 'single_copy_busco_sequences')
        targz_path = base_name+".tar.gz"
        if not os.path.isdir(base_name) and os.path.exists(targz_path):
            cleanupafter = True
            print(f"extracting {sample}")
            with tarfile.open(targz_path) as tf:
                tf.extractall(path=os.path.dirname(base_name))

        for busco in busco_list:
            fna_fname = os.path.join(base_name, busco+".fna")
            faa_fname = os.path.join(base_name, busco+".faa")
            if not os.path.exists(fna_fname):
                continue
            busco_dict[busco]['fna'].append(parse_fasta_dirty(fna_fname, sample))
            busco_dict[busco]['faa'].append(parse_fasta_dirty(faa_fname, sample))

        if cleanupafter == True:
            print(f"remove extracted {sample}")
            shutil.rmtree(base_name)

    return busco_dict


def collect_and_write_busco(busco, busco_seqs, samples_list, base_dir, busco_dataset, output_dir):
    this_busco_fna, this_busco_faa = ["\n".join(x) for x in (busco_seqs[busco]['fna'], busco_seqs[busco]['faa'])]
    with open(os.path.join(output_dir, busco+".fa"), "w") as f:
        f.write(this_busco_fna+"\n")
    with open(os.path.join(output_dir, busco+".faa"), "w") as f:
        f.write(this_busco_faa+"\n")

def collect_and_write_all_buscos(busco_list, samples_list, base_dir, busco_dataset, output_dir):
    os.mkdir(output_dir)
    busco_seqs = collect_buscos_all_samples(busco_list, samples_list, base_dir, busco_dataset)
    iteron_list = [[x, busco_seqs, samples_list, base_dir, busco_dataset, output_dir] for x in busco_list]
    with Pool(16) as p:
        p.starmap(collect_and_write_busco, iteron_list)

def main():
    BUSCO_DATASET = "lepidoptera"
    base_dir = argv[1]
    output_dir = argv[2]
    min_tax_percent = float(argv[3])

    print("Detecting all sample dirs...")
    all_samples = detect_busco_mode(base_dir)
    print("Done.")
    buscos_to_keep = process_all_samples(all_samples, base_dir, BUSCO_DATASET, min_tax_percent)

    print("writing output genewise fastas...")
    collect_and_write_all_buscos(buscos_to_keep,
                                 all_samples, base_dir,
                                 BUSCO_DATASET, output_dir)
    print("Done")



if __name__ == "__main__":
    main()
