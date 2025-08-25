nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"


process MAP_READS_GENOME {

	label 'error_retry'
    label 'process_high'
    cpus params.threads_bigmem
    scratch true

	container = 'https://depot.galaxyproject.org/singularity/mulled-v2-ac74a7f02cebcfcc07d8e8d1d750af9c83b4d45a:f70b31a2db15c023d641c32f433fb02cd04df5a6-0'


    input:
    tuple val(pair_id), path(r1), path(r2), path(idx_bowtie_ch)

    output:
    tuple val(pair_id), path("${pair_id}.mapped.bowtie2.bam"), emit: mappedPE_ch

    script:

    def args = task.ext.args ?: ''


    """
    bowtie2 -p ${task.cpus} ${args} -x ${idx_bowtie_ch} -1 ${r1} -2 ${r2}  | samtools view -hbo ${pair_id}.mapped.bowtie2.bam -
    """

}

