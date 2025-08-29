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


	container = ''


    input:
    tuple val(pair_id), path(mapped_bam), path(mapped_bam_idx)


    output:
    path("${params.projname}.plotFingerprint.pdf")

    script:

    def args = task.ext.args ?: ''


    """
    plotFingerprint ${args} -p ${task.cpus} --bamfiles ${mapped_bam} \
    --labels ${pair_id} \
    --plotFile ${params.projname}.plotFingerprint.pdf 
    """


}