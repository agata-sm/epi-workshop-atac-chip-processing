nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"


process MAP_READS_GENOME {

	label 'error_retry'
    //label 'process_high'
    tag "$pair_id" // Adds name to job submission instead of (1), (2) etc.

    //cpus params.threads_bigmem
    scratch true


	container = 'https://depot.galaxyproject.org/singularity/mulled-v2-ac74a7f02cebcfcc07d8e8d1d750af9c83b4d45a:f70b31a2db15c023d641c32f433fb02cd04df5a6-0'


    input:
    tuple val(pair_id), path(r1), path(r2), path(idx_bowtie2_ch)


    output:
    tuple val(pair_id), path("${pair_id}.mapped.bowtie2.bam"), emit: mappedPE_ch
    path("${prefix}.bowtie2.log")

    script:

    def args = task.ext.args ?: ''


    """
    INDEX=`find -L ./ -name "*.rev.1.bt2" | sed "s/\\.rev.1.bt2\$//"`
    [ -z "\$INDEX" ] && INDEX=`find -L ./ -name "*.rev.1.bt2l" | sed "s/\\.rev.1.bt2l\$//"`
    [ -z "\$INDEX" ] && echo "Bowtie2 index files not found" 1>&2 && exit 1

    bowtie2 -p ${task.cpus} ${args} -x \${INDEX} -1 ${r1} -2 ${r2} 2> >(tee ${prefix}.bowtie2.log >&2) | samtools view -hbo ${pair_id}.mapped.bowtie2.bam - 
    """

}

