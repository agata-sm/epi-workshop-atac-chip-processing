// filt_bam


nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"


process BAM_FILT_MAPQ {

	label 'error_retry'
    label 'process_medium'
    tag "$pair_id" // Adds name to job submission instead of (1), (2) etc.

    //cpus params.threads_bigmem
    scratch true

    container = 'https://depot.galaxyproject.org/singularity/mulled-v2-ac74a7f02cebcfcc07d8e8d1d750af9c83b4d45a:f70b31a2db15c023d641c32f433fb02cd04df5a6-0'

    input:
    tuple val(pair_id), path(mapped_bam)


    output:
    tuple val(pair_id), path("${pair_id}.dedup.filt.bam"), emit: bam_filtq_ch
    path("${pair_id}.dedup.filt.blacklist.stats")
    path("${pair_id}.dedup.filt.mito.stats")

    script:

    def args = task.ext.args ?: ''


    """
    bamutils filter ${mapped_bam} ${pair_id}.dedup.filt1.bam -excludebed ${params.blacklist} nostrand >${pair_id}.dedup.filt.blacklist.stats 2>&1

	bamutils filter ${pair_id}.dedup.filt1.bam ${pair_id}.dedup.filt.bam -excluderef ${params.mt} >${pair_id}.dedup.filt.mito.stats 2>&1
    """

}
