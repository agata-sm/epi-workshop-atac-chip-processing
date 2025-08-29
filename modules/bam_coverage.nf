nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"


process BAM_COVERAGE {

	label 'error_retry'
    label 'process_high'
    tag "$pair_id" // Adds name to job submission instead of (1), (2) etc.

    //cpus params.threads_bigmem
    scratch true


    container = 'https://depot.galaxyproject.org/singularity/deeptools:3.5.1--py_0'


    input:
    tuple val(pair_id), path(mapped_bam)
    tuple val(pair_id), path(mapped_bai)


    output:
    path("${pair_id}.filt.cov_norm1x.bw")

    script:

    def args = task.ext.args ?: ''


    """
    bamCoverage ${args} -p ${task.cpus} \
    --normalizeUsing RPGC --effectiveGenomeSize ${params.efGenSize} --outFileFormat bigwig \
    --bam ${mapped_bam} -outFileName ${pair_id}
    """




}