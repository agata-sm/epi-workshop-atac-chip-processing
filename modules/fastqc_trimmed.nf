nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"



process FASTQC_TRIMMED {

    label 'small'

    tag {smpl_id}
    container = 'https://depot.galaxyproject.org/singularity/fastqc%3A0.12.1--hdfd78af_0'


    input:
    tuple val(smpl_id), path(fastq1), path(fastq2)

    output:
    path('*'), emit: fastqc_report
    path "${params.verfile}"

    script:
    """
    fastqc ${fastq1}
    fastqc ${fastq2}

    echo "Software versions for atac-chip-processing.nf" >${params.verfile}
    date >>${params.verfile}
    echo "process ** fastqc **" >>${params.verfile}
    fastqc -v >>${params.verfile}
    """

}

