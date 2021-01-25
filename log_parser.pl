#!/usr/bin/perl

use strict;
use Time::Piece;

# получаем список файлов
my @files = @ARGV;

my %hash;
my $counter = 0;
# перебираем каждый файл
foreach my $file (@files) {
    $file=~s/,//;

    open(my $fh,'<',$file);
    while (<$fh>) {
        # парсим строки и заносим в хэш разделяя по стартам
        if($_=~/^(.+\s.+)\s(\w):\s(\w+)\s(\w+)/) {
            # статус переносим в lowercase для удобной обработки дальше
            my $a = lc $3;
            my $b = lc $4;
            $hash{$counter}->{$2}->{$a}->{$b} = $1;
        }
        elsif($_=~/SYSTEM/) {
            $counter++;
        }
    }
    close $fh;
}

# прогон каждого старта последовательно
foreach my $counter (sort {$a <=> $b} keys %hash) {
    print "Start $counter:\n";
    # и каждой системы
    foreach my $sysname (sort keys %{$hash{$counter}}) {

        # и каждого процесса
        my @proc = ('start','stop');

        foreach my $proc (@proc) {
            if(${$hash{$counter}}{$sysname}->{$proc}->{'started'}) {
                # перевод времени старта в epochtime
                my $timestart = (Time::Piece->strptime(${$hash{$counter}}{$sysname}->{$proc}->{'started'},"%d.%m.%Y %H:%M:%S"))->strftime("%s");
                if(${$hash{$counter}}{$sysname}->{$proc}->{'complete'}) {
                    # перевод времени стопа в epochtime
                    my $timestop = (Time::Piece->strptime(${$hash{$counter}}{$sysname}->{$proc}->{'complete'},"%d.%m.%Y %H:%M:%S"))->strftime("%s");
                    my $startdiff = $timestop - $timestart;
                    print "$sysname ${proc}ed $startdiff\n";
                }
                else {
                    print "$sysname $proc didn't end\n";
                }
            }
        }
        
    }
}

