nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"


process TRIM_READS_PE {

    label 'mid_mem'

    container = 'https://depot.galaxyproject.org/singularity/cutadapt%3A5.1--py39hbcbf7aa_0'


    input:
    tuple val(pair_id), path(reads)

    output:
    tuple val(pair_id), path("${pair_id}.trimmed_1.fastq.gz"), path("${pair_id}.trimmed_2.fastq.gz"), emit: trimmed_reads_ch
    path("${pair_id}.cutadapt_trim.log"), emit: trimlog_ch

    script:

    def args = task.ext.args ?: ''

    """
    cutadapt -j ${task.cpus} ${args} \
    -o ${pair_id}.trimmed_1.fastq.gz -p ${pair_id}.trimmed_2.fastq.gz $reads >${pair_id}.cutadapt_trim.log 2>&1
 
    echo "Software versions for atac-chip-processing.nf" >${params.verfile}
    date >>${params.verfile}
    echo "process ** trim_reads **" >>${params.verfile}
    cutadapt -v >>${params.verfile}
    """




}