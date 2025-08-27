nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"



process IDX_GENOME {

	label 'error_retry'
    label 'process_high'


	container = 'https://depot.galaxyproject.org/singularity/mulled-v2-ac74a7f02cebcfcc07d8e8d1d750af9c83b4d45a:f70b31a2db15c023d641c32f433fb02cd04df5a6-0'

	input:
    path genomeFasta

    output:
    tuple path("IDX.{1,2,3,4}.bt2"),path("IDX.rev.{1,2}.bt2") , emit: idx_bowtie_ch

    //tuple path("${genomeFasta.baseName}.{1,2,3,4}.bt2"),path("${genomeFasta.baseName}.rev.{1,2}.bt2") , emit: idx_bowtie_ch
    //tuple path("IDX.{1,2,3,4}.bt2"),path("IDX.rev.{1,2}.bt2") , emit: idx_bowtie_ch
	//path("bowtie2"), emit: idx_bowtie_ch
	//path("${genomeFasta}.sizes"), emit: chromsizes_ch

    script:

    def args = task.ext.args ?: ''


    """
    ##gzip -d ${genomeFasta}
    
    bowtie2-build --threads ${task.cpus} ${args} -f ${genomeFasta} IDX

    ##bowtie2-build --threads ${task.cpus} ${args} -f ${genomeFasta} ${genomeFasta.baseName}
    
    ##mkdir bowtie2
    ##bowtie2-build --threads ${task.cpus} ${args} -f ${genomeFasta} bowtie2/${genomeFasta.baseName}

    #samtools faidx ${genomeFasta}
    #cut -f 1,2 ${genomeFasta}.fai > ${genomeFasta}.sizes


    echo "Software versions for atac-chip-processing.nf" >${params.verfile}
    date >>${params.verfile}
    echo "process ** ${task.process} **" >>${params.verfile}
    bowtie2-build --version  >>${params.verfile}

    #echo "reference genome"
    #echo "${genomeFasta}" >>${params.verfile}
    """




}