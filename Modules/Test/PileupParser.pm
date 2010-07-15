{
    package Test::PileupParser;
    use strict;
    use warnings;
    use FindBin qw/$Bin/;
    use lib "$Bin/..";
    use Test;
    use Pileup;
    require Exporter;
    our @ISA = qw(Exporter);
    our @EXPORT=qw(run_PileupParserTests);
    our @EXPORT_OK = qw();
    
    
    sub run_PileupParserTests
    {
        test_parsePileup();
        test_parseExtendedPileup();
    }
    
    sub test_parsePileup
    {
        
        my $res;
        my $pp;
        
        
        # qualencoding,mincount,mincov,maxcov,minqual
        $pp=get_pileup_parser("illumina",2,2,1000000,0);
        $res=$pp->("2L\t90140\tN\t9\tCCccCcCC^FC\t[aaba`aaa");
        is($res->{chr},"2L","parsePileup; chromosome is ok");
        is($res->{pos},90140,"parsePileup; position is ok");
        is($res->{eucov},9,"parsePileup; coverage is ok");
        is($res->{del},0,"parsePileup; del count is ok");
        is($res->{iscov},1,"parsePileup; is covered ok");
        is($res->{issnp},0,"parsePileup; is snp ok");
        is($res->{ispuresnp},0,"parsePileup; is pure snp ok");
        is($res->{A},0,"parsePileup; A count is ok");
        is($res->{T},0,"parsePileup; T count is ok");
        is($res->{C},9,"parsePileup; C count is ok");
        is($res->{G},0,"parsePileup; G count is ok");
        
        # both smaller and lower case characters are recognised
        $res=$pp->("dralala\t2\tN\t9\tAaTtTGggGCCcccNn\taaaaaaaaaaaaaaaa");
        is($res->{chr},"dralala","parsePileup; chromosome is ok");
        is($res->{pos},2,"parsePileup; position is ok");
        is($res->{eucov},14,"parsePileup; coverage is ok");
        is($res->{iscov},1,"parsePileup; is covered ok");
        is($res->{issnp},1,"parsePileup; is snp ok");
        is($res->{ispuresnp},1,"parsePileup; is pure snp ok");
        is($res->{N},2,"parsePileup; N count is ok");
        is($res->{del},0,"parsePileup; del count is ok");
        is($res->{A},2,"parsePileup; A count is ok");
        is($res->{T},3,"parsePileup; T count is ok");
        is($res->{C},5,"parsePileup; C count is ok");
        is($res->{G},4,"parsePileup; G count is ok");
        
        $pp=get_pileup_parser("illumina",2,6,1000000,0);
        $res=$pp->("dralala\t2\tN\t5\tCCCtt\taaatt");
        is($res->{iscov},0,"parsePileup; is covered ok");
        is($res->{issnp},0,"parsePileup; is snp ok");
        
        #quality trimming
        $pp=get_pileup_parser("illumina",2,6,1000000,20);
        $res=$pp->("dralala\t2\tN\t5\tATCGATCGATCG\tZYXWVUTSRQPO");
        is($res->{eucov},7,"parsePileup; coverage is ok");
        is($res->{A},2,"parsePileup; A count is ok");
        is($res->{T},2,"parsePileup; T count is ok");
        is($res->{C},2,"parsePileup; C count is ok");
        is($res->{G},1,"parsePileup; G count is ok");
        
        # replacement
        $pp=get_pileup_parser("illumina",2,4,1000000,0);
        $res=$pp->("drala\t4\tA\t9\tCC.,.\taaaaa");
        is($res->{chr},"drala","parsePileup; chromosome is ok");
        is($res->{pos},4,"parsePileup; position is ok");
        is($res->{eucov},5,"parsePileup; coverage is ok");
        is($res->{iscov},1,"parsePileup; is covered ok");
        is($res->{issnp},1,"parsePileup; is snp ok");
        is($res->{A},3,"parsePileup; A count is ok");
        is($res->{T},0,"parsePileup; T count is ok");
        is($res->{C},2,"parsePileup; C count is ok");
        is($res->{G},0,"parsePileup; G count is ok");
        
        # special pileup characters
        $pp=get_pileup_parser("illumina",2,6,1000000,20);
        $res=$pp->("dralala\t2\tN\t5\tAT^FC\$GATCGATCG\tZYXWVUTSRQPO");
        is($res->{eucov},7,"parsePileup; coverage is ok");
        is($res->{totcov},7,"parsePileup; coverage is ok");
        is($res->{A},2,"parsePileup; A count is ok");
        is($res->{T},2,"parsePileup; T count is ok");
        is($res->{C},2,"parsePileup; C count is ok");
        is($res->{G},1,"parsePileup; G count is ok");
        
        # special pileup characters
        $pp=get_pileup_parser("illumina",2,6,1000000,20);
        $res=$pp->("dralala\t2\tN\t5\tA+12AAAAAAAAAAAAT^FC\$GATCGATCG\tZYXWVUTSRQPO");
        is($res->{eucov},7,"parsePileup; coverage is ok");
        is($res->{A},2,"parsePileup; A count is ok");
        is($res->{T},2,"parsePileup; T count is ok");
        is($res->{C},2,"parsePileup; C count is ok");
        is($res->{G},1,"parsePileup; G count is ok");
        
        $res=$pp->("dralala\t2\tN\t5\tA+2AAT^FC\$G-3CCCATCGATCG\tZYXWVUTSRQPO");
        is($res->{eucov},7,"parsePileup; coverage is ok");
        is($res->{A},2,"parsePileup; A count is ok");
        is($res->{T},2,"parsePileup; T count is ok");
        is($res->{C},2,"parsePileup; C count is ok");
        is($res->{G},1,"parsePileup; G count is ok");
        
        $res=$pp->("dralala\t2\tN\t5\tA-12CCCCCCCCCCCCT^FC\$GATCGATCG\tZYXWVUTSRQPO");
        is($res->{eucov},7,"parsePileup; coverage is ok");
        is($res->{A},2,"parsePileup; A count is ok");
        is($res->{T},2,"parsePileup; T count is ok");
        is($res->{C},2,"parsePileup; C count is ok");
        is($res->{G},1,"parsePileup; G count is ok");
        
        
        # deletions:
        $pp=get_pileup_parser("illumina",2,2,1000000,0);
        $res=$pp->("2L\t90140\tN\t9\tCcGg**\taaaaaa");
        is($res->{chr},"2L","parsePileup; chromosome is ok");
        is($res->{pos},90140,"parsePileup; position is ok");
        is($res->{eucov},4,"parsePileup; coverage is ok");
        is($res->{totcov},6,"parsePileup; coverage is ok");
        is($res->{iscov},1,"parsePileup; is covered ok");
        is($res->{issnp},1,"parsePileup; is snp ok");
        is($res->{A},0,"parsePileup; A count is ok");
        is($res->{T},0,"parsePileup; T count is ok");
        is($res->{N},0,"parsePileup; N count is ok");
        is($res->{C},2,"parsePileup; C count is ok");
        is($res->{G},2,"parsePileup; G count is ok");
        is($res->{del},2,"parsePileup; del count is ok");
        
        $res=$pp->("2L\t90140\tN\t9\tCcGg**Nn\taaaaaaaa");
        is($res->{chr},"2L","parsePileup; chromosome is ok");
        is($res->{pos},90140,"parsePileup; position is ok");
        is($res->{eucov},4,"parsePileup; coverage is ok");
        is($res->{totcov},8,"parsePileup; coverage is ok");
        is($res->{iscov},1,"parsePileup; is covered ok");
        is($res->{issnp},1,"parsePileup; is snp ok");
        is($res->{ispuresnp},0,"parsePileup; is pure snp ok");
        is($res->{A},0,"parsePileup; A count is ok");
        is($res->{T},0,"parsePileup; T count is ok");
        is($res->{N},2,"parsePileup; N count is ok");
        is($res->{C},2,"parsePileup; C count is ok");
        is($res->{G},2,"parsePileup; G count is ok");
        is($res->{del},2,"parsePileup; del count is ok");
    }
    
    sub test_parseExtendedPileup()
    {
        my $pp;
        my $res;
        
        $pp=get_extended_parser("illumina",2,2,1000000,0);
        $res=$pp->("2L\t90140\tN\t9\tCCccCcCC^FC\t[aaba`aaa");
        is($res->{consc},"C","extended parsePileup; consensus character is ok");
        is($res->{consc_confidence},1,"extended parsePileup; confidence is ok");

        # both smaller and lower case characters are recognised
        $res=$pp->("dralala\t2\tN\t9\tAaTTGCCcccNn\taaaaaaaaaaaa");
        is($res->{consc},"C","extended parsePileup; consensus character is ok");
        is($res->{consc_confidence},0.5,"extended parsePileup; confidence is ok");
        
        
    }
    
}
1;