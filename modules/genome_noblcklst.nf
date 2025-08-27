
//genome_noblcklst.nf

nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"


process GENOME_BLACKLIST_REGIONS {

	label 'process_low'

    container = 'https://depot.galaxyproject.org/singularity/bedtools:2.30.0--hc088bd4_0'

    input:
    path genomeFasta
    path chromsizes
    path blacklist

    output:
    path "${genomeFasta.baseName}.noblcklst.bed"  , emit: noblcklst_bed_ch

    //when:
    //task.ext.when == null || task.ext.when

    script:
    """
    sortBed -i ${blacklist}  | complementBed -i stdin -g ${chromsizes} > ${genomeFasta.baseName}.noblcklst.bed
  
    """
}