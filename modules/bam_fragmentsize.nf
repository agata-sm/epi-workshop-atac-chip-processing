nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"


process BAM_FINGERPRINT {

	label 'error_retry'
    label 'process_medium'
    tag "$pair_id" // Adds name to job submission instead of (1), (2) etc.

    //cpus params.threads_bigmem
    scratch true


    container = 'https://depot.galaxyproject.org/singularity/picard:3.1.1--hdfd78af_0'

    input:
    tuple val(pair_id), path(mapped_bam), path(mapped_bai)



    output:
    path("${pair_id}.fraglen.stats")
    path("${pair_id}.fraglen.pdf")


    script:

    def args = task.ext.args ?: ''


    """
    picard \\
        -Xmx${task.memory.giga}g \\
        CollectInsertSizeMetrics \\
        ${args} \\
        --INPUT ${mapped_bam} \\
        --OUTPUT ${pair_id}.fraglen.stats \\
        -H ${pair_id}.fraglen.pdf
    """

}