// filt_bam


nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"


process BAM_FILT_BLCK {

	label 'error_retry'
    label 'process_medium'
    tag "$pair_id" // Adds name to job submission instead of (1), (2) etc.

    //cpus params.threads_bigmem
    scratch true

	container = 'https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27heb79e2c_4'

    input:
    tuple val(pair_id), path(mapped_bam), path(mapped_bam_idx)


    output:
    tuple val(pair_id), path("${pair_id}.dedup.filt.bam"), emit: bam_filt_ch
    path("${pair_id}.dedup.filt.blacklist.stats")
    path("${pair_id}.dedup.filt.mito.stats")

    script:

    def args = task.ext.args ?: ''


    """
    bamutils filter ${mapped_bam} ${pair_id}.dedup.filt1.bam -excludebed ${params.blacklist} nostrand >${pair_id}.dedup.filt.blacklist.stats 2>&1

	bamutils filter ${pair_id}.dedup.filt1.bam ${pair_id}.dedup.filt.bam -excluderef ${params.mt} >${pair_id}.dedup.filt.mito.stats 2>&1
    """

}
