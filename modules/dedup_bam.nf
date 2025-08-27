nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"


process BAM_DEDUP {

	label 'error_retry'
    label 'process_medium'
    tag "$pair_id" // Adds name to job submission instead of (1), (2) etc.

    scratch true

	container = 'https://depot.galaxyproject.org/singularity/picard:3.1.1--hdfd78af_0'

    input:
    tuple val(pair_id), path(mapped_bam), path(mapped_bam_idx)


    output:
    tuple val(pair_id), path("${pair_id}.bowtie2.filt.dedup.bam"),path("${pair_id}.bowtie2.filt.dedup.bam.bai"), emit: bam_dedup_ch
	path("${pair_id}.bowtie2.filt.dedup_metrics")

    script:

    def args = task.ext.args ?: ''


    """   
     picard \\
        -Xmx${task.memory.giga}g \\
        MarkDuplicates \\
        ${args} \\
        --INPUT ${mapped_bam} \\
        --OUTPUT ${pair_id}.bowtie2.filt.dedup.bam \\
        --METRICS_FILE ${pair_id}.bowtie2.filt.dedup_metrics

     picard \\
        -Xmx${task.memory.giga}g \\
         BuildBamIndex \\
        --INPUT ${mapped_bam} \\
        --OUTPUT ${pair_id}.bowtie2.filt.dedup.bam.bai

    """

}

