nextflow.enable.dsl=2
params.local = ''

// versions
params.verfile="software.versions"


process FASTQC_RAW {

    label 'process_single'

    container = 'fastqc%3A0.12.1--hdfd78af_0.img'


    input:
    path fastqfile

    output:
    path('*')
    path "${params.verfile}"

    script:
    """
    fastqc ${fastqfile}

    echo "Software versions for atac-chip-processing.nf" >${params.verfile}
    date >>${params.verfile}
    echo "process ** fastqc **" >>${params.verfile}
    fastqc -v >>${params.verfile}
    """

}