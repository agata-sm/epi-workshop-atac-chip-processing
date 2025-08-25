nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"



process IDX_GENOME {

	label 'error_retry'
	label 'process_medium'
	

	container = 'https://depot.galaxyproject.org/singularity/mulled-v2-ac74a7f02cebcfcc07d8e8d1d750af9c83b4d45a:f70b31a2db15c023d641c32f433fb02cd04df5a6-0'

	input:
    path genomeFasta

    output:
    tuple path('Idx_bowtie2.{1,2,3,4}.bt2'),path('Idx_bowtie2.rev.{1,2}.bt2') , emit: idx_bowtie_ch


    script:

    def args = task.ext.args ?: ''


    """
    gzip -d ${genomeFasta}
    bowtie2-build --threads ${task.cpus} ${args} -f ${genomeFasta} Idx_bowtie2

    echo "Software versions for atac-chip-processing.nf" >${params.verfile}
    date >>${params.verfile}
    echo "process ** idx **" >>${params.verfile}
    bowtie2 -v >>${params.verfile}

    echo "reference genome"
    echo "${genomeFasta}"
    """




}