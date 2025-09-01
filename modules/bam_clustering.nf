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
    path("${params.projname}.plotCorrelation.spearman.pdf")
    path("${params.projname}.plotCorrelation.pearson.pdf")
    path("${params.projname}.all_bams.filt.corr_matrix_bin.pearson.txt")
    path("${params.projname}.all_bams.filt.corr_matrix_bin.spearman.txt")
    path("${params.projname}.all_bams.filt.npz")

    script:

    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''


    """
    multiBamSummary bins  ${args} -p ${task.cpus} --bamfiles ${mapped_bam} \
     -o ${params.projname}.all_bams.filt.npz

    plotCorrelation ${args2} --corData all_bams.filt.npz \
    --outFileCorMatrix ${params.projname}.all_bams.filt.corr_matrix_bin.spearman.txt --whatToPlot heatmap --corMethod spearman \
    --plotFile ${params.projname}.plotCorrelation.spearman.pdf 

    plotCorrelation ${args2} --corData all_bams.filt.npz \
    --outFileCorMatrix ${params.projname}.all_bams.filt.corr_matrix_bin.pearson.txt --whatToPlot heatmap --corMethod pearson \
    --plotFile ${params.projname}.plotCorrelation.pearson.pdf 
    """

}