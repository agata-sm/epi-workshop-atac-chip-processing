nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"


process BAM_CORRELATION {

    label 'error_retry'
    label 'process_high'

    //cpus params.threads_bigmem
    scratch true


    container = 'https://depot.galaxyproject.org/singularity/deeptools:3.5.1--py_0'

    input:
    path(mapped_bam)
    path(mapped_bai)
    //tuple val(pair_id), path(mapped_bai)
    //path(mapped_bai)


    output:
    path("${params.projname}.plotCorrelation.pdf")
    path("all_bams.filt.corr_matrix_bin.txt")
    path("all_bams.filt.npz")

    script:

    def args = task.ext.args ?: ''


    """
    multiBamSummary bins -p ${task.cpus} --bamfiles ${mapped_bam} \
     -o all_bams.filt.npz 

    plotCorrelation --corData all_bams.filt.npz \
    --outFileCorMatrix all_bams.filt.corr_matrix_bin.txt --whatToPlot heatmap --corMethod spearman \
    --plotFile ${params.projname}.plotCorrelation.pdf 
    """

}