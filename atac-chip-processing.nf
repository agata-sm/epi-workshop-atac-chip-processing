/* 
 * Pipeline for processing of ChIP-seq and ATAC-seq data
 * includes basic QC steps
 * Written for NBIS Epigenomics Workshop
 * 
 * Author: Agata Smialowska
 * August 2025
 */ 




nextflow.enable.dsl=2


/* 
 * pipeline input parameters 
 */
params.resdir = "results"
params.projdir = "$launchDir/${params.projname}"

params.outdir = "${params.projdir}/${params.resdir}"

params.logdir = 'logs'


params.fastqPE="${params.fastqdir}/*_{1,2}.fastq.gz" // SRA file naming convention
params.fastq="${params.fastqdir}/*fastq.gz"





log.info """\
 ATAC ChIP processing pipeline
 ===================================
 fastq files directory: ${params.fastqdir}
 reference genome: ${params.genomeFa}
 outdir       : ${params.outdir}

 """
 .stripIndent()

println ""


/////////////////////////////
// channels

//fastq files channel for PE
read_pairs = Channel.fromFilePairs(params.fastqdir, checkIfExists: true )
	read_pairs
	    .view()
	    .set { read_pairs }



// fastq file paths channel - paths
fastq_ch= Channel.fromPath(params.fastqdir , checkIfExists:true)
	fastq_ch
	    .view()
	    .set { fastq_ch }


// fa for index
fa_ch=Channel.fromPath(params.genomeFa , checkIfExists:true)


// blacklists
blacklist_ch= Channel.fromPath(params.blacklist, checkIfExists:true)
	blacklist_ch
		//.view()
		.set { blacklist_ch }



/////////////////////////////
// processes
include { FASTQC_RAW     } from "$projectDir/modules/fastqc_raw.nf"
include { TRIM_READS_PE          } from "$projectDir/modules/trim_reads.nf"
include { FASTQC_TRIMMED           } from "$projectDir/modules/fastqc_trimmed.nf"
include { IDX_GENOME            } from "$projectDir/modules/idx_genome.nf"
include { MAP_READS_GENOME      } from "$projectDir/modules/map_reads_genome.nf"




/////////////////////////////
// workflows

//default non subset files

workflow {

	//QC
	FASTQC_RAW(fastq_ch)

	TRIM_READS_PE(read_pairs)

	trimmed_reads_PE_ch=TRIM_READS_PE.out.trimmed_reads_ch

	FASTQC_TRIMMED(trimmed_reads_PE_ch)

	//index
	IDX_GENOME(fa_ch)

	//read mapping
	idx_bowtie_ch=IDX_GENOME.out.idx_bowtie_ch
		idx_bowtie_ch
			.flatten()
			.collect()
			.map{[it]}
			//.view()
			.set{ idx_bowtie_ch }


	map_readsPE_ch=TRIM_READS_PE.out.trimmed_reads_ch
		map_readsPE_ch
			.combine(idx_bowtie_ch)
			//.view()
			.set {map_readsPE_ch}


	MAP_READS_GENOME(map_readsPE_ch)



}

