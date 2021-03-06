#!/usr/bin/perl
use warnings;
use strict;
use FindBin;
use lib "$FindBin::Bin/Lib";

use Tools;
use Configuration;

use threads;
use threads::shared;
use Thread::Queue;

my $q = Thread::Queue->new();
die "usage: perl $0 <Config file>\n\n" unless $#ARGV==0;
my $Config = Configuration->new($ARGV[0]);

my $nThreads = $Config->get("OPTIONS","Threads");

warn "Recognizing $nThreads as max threading...\n";

my $ref=$Config->get("PATHS","reference");
warn "Finding Vectors...\n";
my $vecDir = $Config->get("PATHS","vector_dir");
my @LineNo = $Config->getAll("VECTORS");

foreach my $i (@LineNo){
      $q->enqueue($i);
}
for(my$i=0;$i<1;$i++){
      my $thr=threads->create(\&worker);
}
while(threads->list()>0){
      my @thr=threads->list();
      $thr[0]->join();
}


sub worker {
	my $TID=threads->tid() -1 ;
	while(my$j=$q->dequeue_nb()){
		my ($R1,$R2)=split(/\,/,$Config->get("DATA",$j));
		my $prefix = $Config->get("CELL_LINE",$j);
		my $P1=$Config->get("DIRECTORIES","filtered_dir")."/".$prefix.".R1.fastq";
		my $P2=$Config->get("DIRECTORIES","filtered_dir")."/".$prefix.".R2.fastq";
		my $cmd = "wc -l $P1";
		open(CMD,"-|",$cmd);
		my @output = <CMD>;
		close CMD;
		my $num = $output[0];
		$num=~s/\s+.+//;
		$cmd = "wc -l $P2";
		open(CMD,"-|",$cmd);
		@output = <CMD>;
		$output[0]=~s/\s+.+//;
		close CMD;
		$num+=$output[0];
		$num=$num/4;
		print $prefix."\t".$num."\n";
	}
}

# /home/ec2-user/Store1/bin/delly  -t TRA -o TRA.vcf -q 20 -g TwoChrom.fasta pGC1_Raw.sorted.bam

exit(0);


