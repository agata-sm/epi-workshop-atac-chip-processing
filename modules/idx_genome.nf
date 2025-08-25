nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"



process IDX_GENOME {

	label 'genome_idx'
	label 'mid_mem'

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