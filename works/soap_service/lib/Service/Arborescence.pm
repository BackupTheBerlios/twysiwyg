package Service::Arborescence;

use Service::Conversions;

# =========================
=pod

---+++ getTopicName( $web ) ==> @topics

| Description: | Get list of all topics in a web |
| Parameter: =$web= | Web name, required, e.g. ="Sandbox"= |
| Return: =@topics= | Topic list, e.g. =( "WebChanges",  "WebHome", "WebIndex", "WebNotify" )= |

=cut
# -------------------------
sub getTopicName
{
	my( $web,$key ) = @_ ;
	my @topicListTXT;

    if( !defined $web ) {
	$web="";
    }

    #FIXME untaint web name?

	# get list of all topics by scanning $dataDir
    opendir DIR, "$web" ;
    my @tmpList = readdir( DIR );
    closedir( DIR );
    
    # this is not magic, it just looks like it.
    my @topicList = sort
        grep { s#^.+/([^/]+)\.txt$#$1# }
        grep { ! -d }
        map  { "$web/$_" }
        grep { ! /^\.\.?$/ } @tmpList;
	
	
	
	foreach $all (@topicList)
	{
	  open(FILE,"$web/$all.txt") || die "Erreur majeur, fichier non accessible $all" ;
	  while(<FILE>)	
	  {
		my $temp=<FILE>;
		if(/%META:TOPICINFO{/)
		{
			if($temp =~ /%META:TOPICPARENT/)
			{
			  $webn=&giveWebName("$web/$all.txt");
		      $topic=&Service::Editeur::giveTopicName("$web/$all.txt");
			  if(&isView($key,$webn,$topic))
			  {
			    push(@topicListTXT,"$all.txt");
			  }
			}
		}
	  } 
	  close(FILE);	
	}
    return @topicListTXT ; 
}



# =========================
=pod

---+++ listWeb( $web ) ==> @liste

| Description: | Get list of all file and Webs in a web without . and ..|
| Parameter: =$web= | Web name, required, e.g. ="Sandbox"= |
| Return: =@liste= | Topic and Web list, e.g. =( "WebChanges.txt",  "toto.tgz", "SubWeb" )= |

=cut
# -------------------------
sub listWeb
{
opendir ( DIR , $_[0] ) ; 
@list = readdir ( DIR ) ;
closedir ( DIR ) ;
return @list;
}

#liste des fichiers sans .. et .
sub listWebClean
{
 opendir ( DIR , $_[0]) ; 
 my $taille = 0;
 @clean;
 while (defined($file = readdir(DIR))) 
 { 
      if ($file !~ /^\.\.?$/) 
      { 
            # pas '..' et '.' 
            $clean[$taille]=$file;
            $taille++;
      }
 }
 closedir ( DIR ) ;
 return @clean; 
}

# =========================
=pod

---+++ listWebCleanType( $web ) ==> @liste

| Description: | Get list of all file and Webs in a web without . and .. , and specifi if it's a Web or a topic|
| Parameter: =$web= | Web name, required, e.g. ="Sandbox"= |
| Return: =@liste= | Topic and Web list, e.g. =( "WebChanges.txt","topic",  "toto.txt,v","topic", "SubWeb","Web" )= |

=cut
# -------------------------
sub listWebCleanType
{
 opendir ( DIR , $_[0]) ; 
 my $taille = 0;
 @clean;
 while (defined($file = readdir(DIR))) 
 { 
      if ($file !~ /^\.\.?$/) 
      { 
            # pas '..' et '.' 
            push(@clean,"$_[0]/$file");
            (-d "$_[0]/$file")? push(@clean,"Web"): push(@clean,"topic");
            
      }
 }
 closedir ( DIR ) ;
 return @clean; 
}


# =========================
=pod

---+++ giveSousWeb( $web ) ==> @liste

| Description: | Get all SubWebs in a web |
| Parameter: =$web= | Web name, required, e.g. ="Sandbox"= |
| Return: =@liste= | SubWeb list, e.g. =( "SubWeb1","SubWeb2" )= |

=cut
# -------------------------
sub giveSousWeb
{
opendir ( DIR , $_[0]) ; 
 my $taille = 0;
 @clean;
 while (defined($file = readdir(DIR))) 
 { 
      if ($file !~ /^\.\.?$/) 
      { 
            # pas '..' et '.' 
            
            if(-d $_[0]."/".$file)
            {
				$clean[$taille]=$file;
				$taille++;
            }
      }
 }
 closedir ( DIR ) ;
 return @clean; 
}


# =========================
=pod

---+++ giveTopicsWeb( $web ) ==> @liste

| Description: | Get list of all topics in this web |
| Parameter: =$web= | Web name, required, e.g. ="Sandbox"= |
| Return: =@liste= | SubWeb list, e.g. =( "topic1.txt","topic2.txt" )= |

=cut
# -------------------------
sub giveTopicsWeb
{
opendir ( DIR , $_[0]) ; 
 @clean;
 while (defined($file = readdir(DIR))) 
 { 
      if ($file !~ /^\.\.?$/) 
      { 
            # pas '..' et '.' 
            
            unless(-d $_[0]."/".$file)
            {
				if(!($file =~ /,v/)&& !($file =~ /.lock/)) 
				{
				  push(@clean,$file);
				}
				
            }
      }
 }
 closedir ( DIR ) ;
 return @clean; 
}


# =========================
=pod

---+++ giveTopicsPath( $web,$key ) ==> @liste

| Description: | Get list of all topics in this web and these subWeb with there topics'paths |
| Parameter: =$web= | Web name, required, e.g. ="Sandbox"= |
| Parameter: =$key= | key , required, e.g. =125= |
| Return: =@liste= | SubWeb list, e.g. =( "/know/topic1.txt","/Main/topic2.txt" )= |

=cut
# -------------------------
#recupere la liste de tous les topics à partir d'un rep donné
# chaque topics est associé à son chemin data/know/topic
sub giveTopicsPath {
  my $repertoire = shift;
  my $key = shift;
  my $enregistrement;
  my $nom_chemin;
  @topics;
  local *DH;

  unless (opendir(DH, $repertoire)) 
  {
   return;
  }
  
  while (defined ($enregistrement = readdir(DH))) 
  {
   next if($enregistrement eq "." or $enregistrement eq "..");
   $nom_chemin = $repertoire."/".$enregistrement;
   unless(-d $nom_chemin  )
   {
	unless($nom_chemin =~ /txt.v$/) 
      {
		$web=&giveWebName($nom_chemin);
		$topic=&Service::Editeur::giveTopicName($nom_chemin);
        if(&isView($key,$web,$topic))
        {
          push(@topics,$nom_chemin);
		}
      }
   }
   giveTopicsPath($nom_chemin,$key) if(-d $nom_chemin);
  }
 closedir(DH);
 return @topics;
}


# =========================
=pod

---+++ giveTopics( $web,$key ) ==> @liste

| Description: | Get list of all topics in this web and these subWeb with there topics'names|
| Parameter: =$web= | Web name, required, e.g. ="Sandbox"= |
| Parameter: =$key= | key , required, e.g. =125= |
| Return: =@liste= | SubWeb list, e.g. =( "topic1.txt","topic2.txt" )= |

=cut
# -------------------------
#recupere la liste de tous les topics à partir d'un rep donné
# chaque topics est representé que par son nom.
sub giveTopics
{
 opendir(DIR,$_[0]) || die "Erreur majeur, fichier non accessible" ;
 @topics;
 $taille;
 while(defined($file = readdir(DIR)))
 {
	
	if ($file !~ /^\.\.?$/) 
      { 
        # pas '..' et '.' 
		if(-d $_[0]."/".$file)
		{
			@temp=giveTopics($_[0]."/".$file);
			$i=@temp;
			$taille+=$i;
			push(@topics,@temp);
		}	
		else #beh forcement c un fichier
		{
			$topics[$taille]=$file;
			$taille++;
		}
	  }
 }
 close(DIR);
 return @topics;
}

# =========================
=pod

---+++ giveTopicParent( $topic ) ==> $parent

| Description: | Get the parent of the topic|
| Parameter: =$topic= | topic name, required, e.g. ="WebHome"= |
| Return: =$parent= | parent of the topic,e.g. ="WebHome"=|

=cut
# -------------------------
#retourne le topic parent du topic passe en parametre
sub giveTopicParent
{
	my $parent;
	#my $file="$TWiki::dataDir/$_[0]";
	my $file="$_[0]";
	open(FILE,$file) || die "Erreur majeur, fichier non accessible" ;
	
	while(<FILE>)
	{
		if(/TOPICPARENT{name="/)
		{
			$tmp=$';
			if($' =~ /"/)
			{
				$parent=$`;
				return $parent;
			}
		}
		else
		{
				$parent="";
		}
	}
	close(FILE);
	return $parent;
}

# =========================
=pod

---+++ giveTopicSize( $topic ) ==> $size

| Description: | Get the size of the topic|
| Parameter: =$topic= | topic name, required, e.g. ="WebHome"= |
| Return: =$size= | size of the topic,e.g. =12054=|

=cut
# -------------------------
#retourne la taille du topic passe en parametre             
sub giveTopicSize
{
	open(FILE,$_[0]) || die "Erreur majeur, fichier non accessible" ;
	$size=(stat FILE)[7];
	close(FILE);
	return $size;
}

# =========================
=pod

---+++ giveTopicWeb( $topic ) ==> $web

| Description: | Get the web of the topic|
| Parameter: =$topic= | topic name, required, e.g. ="WebHome"= |
| Return: =$web= | web of the topic,e.g. ="Main"=|

=cut
# -------------------------
#retourne le web dans lequel est present le topic
sub giveTopicWeb
{
	my @chaine=split("/",$_[0]);
	pop(@chaine);
	$taille=@chaine;
	my $val;
	for($i=0;$i<$taille-1;$i++)
	{$val.=$chaine[$i]."/";}
	$val.=$chaine[$taille-1];
	return $val;
}

# =========================
=pod

---+++ giveTopicPath( $topic ) ==> $path

| Description: | Get the path of the topic|
| Parameter: =$topic= | topic name, required, e.g. ="WebHome"= |
| Return: =$path= | path of the topic,e.g.="/Main/tititi.txt"|

=cut
# -------------------------
#retourne le chemin du topic /Main/tititi.txt
sub giveTopicPath
{
	my @chaine=split("/",$_[0]);
	pop(@chaine);
	my $taille=@chaine;
	my $val;
	for($i=0;$i<$taille-1;$i++)
	{
	  $val.=$chaine[$i]."/";
	}
	$val.=$chaine[$taille-1];
	if($val =~ /\/data\//)
	{
		return $';
	}
	return $val;
}



# =========================
=pod

---+++ giveTopicAutheur( $topic ) ==> $author

| Description: | Get the author of the topic|
| Parameter: =$topic= | topic name, required, e.g. ="WebHome"= |
| Return: =$path= | author of the topic,e.g.="Maxime"|

=cut
# -------------------------
#retourne l'autheur du topic
sub giveTopicAutheur
{
	my $autheur;
	open(FILE,$_[0]) || die "Erreur majeur, fichier non accessible $_[0]" ;
	
	while(<FILE>)
	{
		if(/author="/)
		{
			$tmp=$';
			if($' =~ /"/)
			{
				$autheur=$`;
			}
		}
	}
	close(FILE);
	return $autheur;
}

# =========================
=pod

---+++ giveTopicCreation( $topic ) ==> $date

| Description: | Get the date when the topic was created|
| Parameter: =$topic= | topic name, required, e.g. ="WebHome"= |
| Return: =$date= | the date when the topic was created in seconds,e.g.="6541951"|

=cut
# -------------------------
#retourne la date de creation
sub giveTopicCreation
{
	my $autheur;
	open(FILE,$_[0]) || die "Erreur majeur, fichier non accessible" ;
	
	while(<FILE>)
	{
		if(/date="/)
		{
			$tmp=$';
			if($' =~ /"/)
			{
				$autheur=$`;
			}
		}
	}
	close(FILE);
	return &convert_date($autheur);
}

# =========================
=pod

---+++ convert_date( $date ) ==> $format

| Description: | Get the date in a special format|
| Parameter: =$date= | date , required in seconds, e.g. ="6445165"= |
| Return: =$format= | the date in a special format,e.g.="lundi 18 octobre 2005 15 h 58 mn 17 s"|

=cut
# -------------------------
#retourne la date formate
sub convert_date
{
 ($sec, $min, $h, $j, $m, $a, $sj, $aj, $isdst) = localtime $_[0];

 $mois = (qw(janvier février mars avril mai juin 
 juillet aout septembre octobre novembre decembre))[$m];

 $jour = (qw(dimanche lundi mardi mercredi jeudi vendredi samedi))[$sj];

 $annee = $a + 1900;

 my $cdate="$jour $j $mois $annee $h h $min mn $sec s";

 return $cdate;
}

# =========================
=pod

---+++ giveTopicModification( $topic ) ==> $date

| Description: | Get the date when the topic was changed|
| Parameter: =$topic= | topic name, required, e.g. ="WebHome"= |
| Return: =$date= | the date when the topic was changed in seconds,e.g.="6541951"|

=cut
# -------------------------
#retourne la date de derniere modification              
sub giveTopicModification
{
	open(FILE,$_[0]) || die "Erreur majeur, fichier non accessible" ;
	my $creat=(stat FILE)[9];
	close(FILE);
	return &convert_date($creat);
}

# =========================
=pod

---+++ giveTopicVersion( $topic ) ==> $ver

| Description: | get the version of the topic|
| Parameter: =$topic= | topic name, required, e.g. ="WebHome"= |
| Return: =$ver= | the version of the topic,e.g.="1.0"|

=cut
# -------------------------
#retourne la version du topic
sub giveTopicVersion
{
	my $autheur;
	open(FILE,$_[0]) || die "Erreur majeur, fichier non accessible" ;
	
	while(<FILE>)
	{
		if(/version="/)
		{
			my $tmp=$';
			if($' =~ /"/)
			{
				$autheur=$`;
			}
		}
	}
	close(FILE);
	return $autheur;
}

# =========================
=pod

---+++ giveTopicFormat( $topic ) ==> $format

| Description: | get the format of the topic|
| Parameter: =$topic= | topic name, required, e.g. ="WebHome"= |
| Return: =$format= | the format of the topic,e.g.="1.1"|

=cut
# -------------------------
#retourne le format du topic
sub giveTopicFormat
{
	my $autheur;
	open(FILE,$_[0]) || die "Erreur majeur, fichier non accessible" ;
	
	while(<FILE>)
	{
		if(/format="/)
		{
			$tmp=$';
			if($' =~ /"/)
			{
				$autheur=$`;
			}
		}
	}
	close(FILE);
	return $autheur;
}

# =========================
=pod

---+++ listWebSize( $web ) ==> $size

| Description: | get the size of the web, not the recursive one|
| Parameter: =$web= | web name, required, e.g. ="Main"= |
| Return: =$size= | the size of the Web in octets ,e.g.="1568761"|

=cut
# -------------------------
#renvoie la taille d'un repertoire
#cette taille n'est pas recursive, comme c le cas dans les explorateurs
sub listWebSize
{
 opendir ( DIR , $_[0]) || die "Erreur majeur, fichier non accessible"; 
 my $taillef = 0;
 while (defined($file = readdir(DIR))) 
 { 
      if ($file !~ /^\.\.?$/) 
      { 
            # pas '..' et '.' 
            ($dev,$inode,$perm,$liens,$uid,$gid,$ndev,$lg,$acces,$mod,$cr,$blksize,$bl)=stat("$_[0]/".$file);
			$taillef += $lg;     
      }
 }
 closedir ( DIR ) ;
 return $taillef; 
}

# =========================
=pod

---+++ giveWebName( $path ) ==> $name

| Description: | get the name of the web based of the path of the web|
| Parameter: =$path= | the web path, required, e.g. ="Main/SubMain"= |
| Return: =$name= | the name of the web based of the path of the web ,e.g.="SubMain"|

=cut
# -------------------------
#renvoi que le nom du Web a partir du chemin
sub giveWebName
{
  my $temp;
  my @chaine=split("/",$_[0]);
  $temp=@chaine; 
  if($chaine[$temp-1] =~ /.txt/)
  {
	return $chaine[$temp-2];
  }
  else
  {
	return $chaine[$temp-1	];
  }
}

# =========================
=pod

---+++ isView( $key,$web,$topic ) ==> $num

| Description: | say if the topic can be viewed by the user|
| Parameter: =$key= | the key to identifie the user, required, e.g. ="125"= |
| Parameter: =$web= | the web where the topic is, required, e.g. ="Main"= |
| Parameter: =$topic= | the name of the topic, required, e.g. ="toto"= |
| Return: =$num= | 0 if he the topic can be view, 1 either ,e.g.="1|

=cut
# -------------------------
#cette fonction pemet de savoir si un topic est visible pour l'utilisateur de clé $key
sub isView
{
	my($key,$web,$topic)=@_;
	my $log=&Service::Connection::getLogin($key);
	$userName=&Service::Connection::initialize($log,$web,$topic);
	if(&Service::Topics::hasPermissions($web,$topic,$log,"view"))
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

# =========================
=pod

---+++ isWrite( $key,$web,$topic ) ==> $num

| Description: | say if the user has the right of write|
| Parameter: =$key= | the key to identifie the user, required, e.g. ="125"= |
| Parameter: =$web= | the web where the topic is, required, e.g. ="Main"= |
| Parameter: =$topic= | the name of the topic, required, e.g. ="toto"= |
| Return: =$num= | 0 if no right, 1 for the right  of change, 2 for the right of rename and 3 for both change and rename ,e.g.="1"|

=cut
# -------------------------
#permet de connaitre les proprietes d'ecriture d'un topic
# 0 ==> none
# 1 ==> change
# 2 ==> rename
# 3 ==> chnage + rename
sub isWrite
{
	my($key,$web,$topic)=@_;
	my $result=0;
	my $log=&Service::Connection::getLogin($key);
	$userName=&Service::Connection::initialize($log,$web,$topic);
	if(&Service::Topics::hasPermissions($web,$topic,$log,"change"))
	{
		$result=1;
	}
	if(&Service::Topics::hasPermissions($web,$topic,$log,"rename"))
	{
		if($result eq 1)
		{
			$result=3
		}
		else
		{
			$result=2;
		}
	}
	return $result;
}

# =========================
=pod

---+++ format( $data ) ==> $text

| Description: | convert the specials caracters|
| Parameter: =$data= | the data of a text, required, e.g. ="été"= |
| Return: =$text= | the data formated,e.g.="&eacute;t&eacute;"|

=cut
# -------------------------
sub format
{
  my ($text)=@_;
  my $temp=$text;
  
  $text=~ s/à/&agrave;/;
  $text=~ s/á/&aacute;/;
  $text=~ s/â/&acirc;/;
  $text=~ s/ã/&atilde;/;
  $text=~ s/ä/&auml;/;
  $text=~ s/å/&aring;/;
  $text=~ s/æ/&aelig;/;
  $text=~ s/ç/&ccedil;/;
  $text=~ s/è/&egrave;/;
  $text=~ s/é/&eacute;/;
  $text=~ s/ê/&ecirc;/;
  $text=~ s/ë/&euml;/;
  $text=~ s/ì/&igrave;/;
  $text=~ s/í/&iacute;/;
  $text=~ s/î/&icirc;/;
  $text=~ s/ï/&iuml;/;
  $text=~ s/ð/&eth;/;
  $text=~ s/ñ/&ntilde;/;
  $text=~ s/ò/&ograve;/;
  $text=~ s/ó/&oacute;/;
  $text=~ s/ô/&ocirc;/;
  $text=~ s/õ/&otilde;/;
  $text=~ s/ö/&ouml;/;
  $text=~ s/ù/&ugrave;/;
  $text=~ s/ú/&uacute;/;
  $text=~ s/û/&ucirc;/;
  $text=~ s/ü/&uuml;/;    
  $text=~ s/À/&Agrave;/;
  $text=~ s/Á/&Aacute;/;
  $text=~ s/Â/&Acirc;/;
  $text=~ s/Ã/&Atilde;/;
  $text=~ s/Ä/&Auml;/;
  $text=~ s/Å/&Aring;/;
  $text=~ s/Æ/&AElig;/;
  $text=~ s/Ç/&Ccedil;/;
  $text=~ s/È/&Egrave;/;
  $text=~ s/É/&Eacute;/;
  $text=~ s/Ê/&Ecirc;/;
  $text=~ s/Ë/&Euml;/;
  $text=~ s/Ì/&Igrave;/;
  $text=~ s/Í/&Iacute;/;
  $text=~ s/Î/&Icirc;/;
  $text=~ s/Ï/&Iuml;/;
  $text=~ s/Ð/&ETH;/;
  $text=~ s/Ñ/&Ntilde;/;
  $text=~ s/Ò/&Ograve;/;
  $text=~ s/Ó/&Oacute;/;
  $text=~ s/Ô/&Ocirc;/;
  $text=~ s/Õ/&Otilde;/;
  $text=~ s/Ö/&Ouml;/;
  $text=~ s/Ø/&Oslash;/;
  $text=~ s/Ù/&Ugrave;/;
  $text=~ s/Ú/&Uacute;/;
  $text=~ s/Û/&Ucirc;/;    
  $text=~ s/Ü/&Uuml;/;
  $text=~ s/Ý/&Yacute;/;
  $text=~ s/Þ/&THORN;/;
  $text=~ s/ß/&szlig;/;
  $text=~ s/÷/&Agrave;/;
  $text=~ s/†/&dagger;/;
  $text=~ s/‡/&Dagger;/;
  $text=~ s/‰/&permil;/;
  $text=~ s/‹/&lsaquo;/;
  $text=~ s/›/&rsaquo;/;
  $text=~ s/™/&trade;/;
  #$text=~ s/%/&#37;/;
  #$text=~ s/>/&gt;/;
  #$text=~ s/</&lt;/;
  #$text=~ s/^/&#94;/;
  $text=~ s/`/&#96;/;
  $text=~ s/~/&#126;/;
  $text=~ s/¡/&iexcl;/;
  $text=~ s/¢/&cent;/;
  $text=~ s/£/&pound;/;
  $text=~ s/¤/&curren;/;
  $text=~ s/¥/&yen;/;
  $text=~ s/§/&sect;/;
  $text=~ s/¨/&uml;/;
  $text=~ s/©/&copy;/;
  $text=~ s/ª/&ordf;/;
  $text=~ s/«/&laquo;/;
  $text=~ s/¬/&not;/;
  $text=~ s/®/&reg;/;
  $text=~ s/°/&deg;/;
  $text=~ s/±/&plusmn;/;    
  $text=~ s/µ/&micro;/;
  $text=~ s/¶/&para;/;
  $text=~ s/»/&raquo;/;
  $text=~ s/ÿ/&yuml;/;
  $text=~ s/²/&sup2;/;
  $text=~ s/³/&sup3;/;
  return $text;
}



# =========================
=pod

---+++ format( $data ) ==> $text

| Description: | convert unicode caracters|
| Parameter: =$data= | the data of a text, required, e.g. ="&eacute;t&eacute;"= |
| Return: =$text= | the data formated,e.g.="été"|

=cut
# -------------------------
sub reformat
{
  my ($text)=@_;
  my $temp=$text;
  
  $text=~ s/&agrave;/à/;
  $text=~ s/&aacute;/á/;
  $text=~ s/&acirc;/â/;
  $text=~ s/&atilde;/ã/;
  $text=~ s/&auml;/ä/;
  $text=~ s/&aring;/å/;
  $text=~ s/&aelig;/æ/;
  $text=~ s/&ccedil;/ç/;
  $text=~ s/&egrave;/è/;
  $text=~ s/&eacute;/é/;
  $text=~ s/&ecirc;/ê/;
  $text=~ s/&euml;/ë/;
  $text=~ s/&igrave;/ì/;
  $text=~ s/&iacute;/í/;
  $text=~ s/&icirc;/î/;
  $text=~ s/&iuml;/ï/;
  $text=~ s/&eth;/ð/;
  $text=~ s/&ntilde;/ñ/;
  $text=~ s/&ograve;/ò/;
  $text=~ s/&oacute;/ó/;
  $text=~ s/&ocirc;/ô/;
  $text=~ s/&otilde;/õ/;
  $text=~ s/&ouml;/ö/;
  $text=~ s/&ugrave;/ù/;
  $text=~ s/&uacute;/ú/;
  $text=~ s/&ucirc;/û/;
  $text=~ s/&uuml;/ü/;    
  $text=~ s/&Agrave;/À/;
  $text=~ s/&Aacute;/Á/;
  $text=~ s/&Acirc;/Â/;
  $text=~ s/&Atilde;/Ã/;
  $text=~ s/&Auml;/Ä/;
  $text=~ s/&Aring;/Å/;
  $text=~ s/&AElig;/Æ/;
  $text=~ s/&Ccedil;/Ç/;
  $text=~ s/&Egrave;/È/;
  $text=~ s/&Eacute;/É/;
  $text=~ s/&Ecirc;/Ê/;
  $text=~ s/&Euml;/Ë/;
  $text=~ s/&Igrave;/Ì/;
  $text=~ s/&Iacute;/Í/;
  $text=~ s/&Icirc;/Î/;
  $text=~ s/&Iuml;/Ï/;
  $text=~ s/&ETH;/Ð/;
  $text=~ s/&Ntilde;/Ñ/;
  $text=~ s/&Ograve;/Ò/;
  $text=~ s/&Oacute;/Ó/;
  $text=~ s/&Ocirc;/Ô/;
  $text=~ s/&Otilde;/Õ/;
  $text=~ s/&Ouml;/Ö/;
  $text=~ s/&Oslash;/Ø/;
  $text=~ s/&Ugrave;/Ù/;
  $text=~ s/&Uacute;/Ú/;
  $text=~ s/&Ucirc;/Û/;    
  $text=~ s/&Uuml;/Ü/;
  $text=~ s/&Yacute;/Ý/;
  $text=~ s/&THORN;/Þ/;
  $text=~ s/&szlig;/ß/;
  $text=~ s/&Agrave;/÷/;
  $text=~ s/&dagger;/†/;
  $text=~ s/&Dagger;/‡/;
  $text=~ s/&permil;/‰/;
  $text=~ s/&lsaquo;/‹/;
  $text=~ s/&rsaquo;/›/;
  $text=~ s/&trade;/™/;
  #$text=~ s/%/&#37;/;
  #$text=~ s/>/&gt;/;
  #$text=~ s/</&lt;/;
  #$text=~ s/^/&#94;/;
  $text=~ s/&#96;/`/;
  $text=~ s/&#126;/~/;
  $text=~ s/&iexcl;/¡/;
  $text=~ s/&cent;/¢/;
  $text=~ s/&pound;/£/;
  $text=~ s/&curren;/¤/;
  $text=~ s/&yen;/¥/;
  $text=~ s/&sect;/§/;
  $text=~ s/&uml;/¨/;
  $text=~ s/&copy;/©/;
  $text=~ s/&ordf;/ª/;
  $text=~ s/&laquo;/«/;
  $text=~ s/&not;/¬/;
  $text=~ s/&reg;/®/;
  $text=~ s/&deg;/°/;
  $text=~ s/&plusmn;/±/;    
  $text=~ s/&micro;/µ/;
  $text=~ s/&para;/¶/;
  $text=~ s/&raquo;/»/;
  $text=~ s/&yuml;/ÿ/;
  $text=~ s/&sup2;/²/;
  $text=~ s/&sup3;/³/;
  return $text;
}

# =========================
=pod

---+++ sameParent( $parent,$rep,$key ) ==> @list

| Description: | list of topics whose parent is $parent|
| Parameter: =$parent= | the parent topic, required, e.g. ="WebHome"= |
| Parameter: =$rep= | the Web where the search start, required, e.g. ="Main"= |
| Parameter: =$key= | the key to identifie the user, required, e.g. ="125"= |
| Return: =@list= | the list of topics whose parent is $parent,e.g.=("/Main/tutu.txt","/tata.txt")|

=cut
# -------------------------
sub sameParent
{
  my($parent,$rep,$key)=@_;  
  my $cmd= "$TWiki::egrepCmd -l -r  TOPICPARENT{name=.$parent.} $rep";
  my @same2=`$cmd`;
  my @same;
  foreach $toto (@same2)
  {
	$web=&giveWebName($toto);
	$topic=&Service::Editeur::giveTopicName($toto);
	if(&isView($key,$web,$topic))
	{
		if($toto =~ /data\//)
		{
		   push(@same,$');
		}
	}
  }
  return @same;
}


############################
### Fonctions Web Serice ###
############################

# =========================
=pod

---+++ giveTopicProperties( $topic,$key ) ==> @list

| Description: | list of topics properties |
| Parameter: =$topic= | the topic, required, e.g. ="WebHome.txt"= |
| Parameter: =$key= | the key to identifie the user, required, e.g. ="125"= |
| Return: =@list= | the list of topics whose parent is $parent
                    ,e.g.=("size","webname","topicPath","topicParent","topicAuthor","dateCreate","dateChange","version","format","mode")|

=cut
# -------------------------
#retourne les propriete d'un topics
sub giveTopicProperties
{
 my $object = shift;
 my ( $topic,$key ) = @_;
 $topic=$TWiki::dataDir."/".$topic;
 my @properties;
 
 push(@properties,&giveTopicSize($topic)); 
 push(@properties,&format(&giveWebName($topic))); 
 push(@properties,&format(&giveTopicPath($topic))); 
 push(@properties,&format(&giveTopicParent($topic)));
 push(@properties,&format(&giveTopicAutheur($topic)));
 push(@properties,&giveTopicCreation($topic)); 
 push(@properties,&giveTopicModification($topic)); 
 push(@properties,&giveTopicVersion($topic));
 push(@properties,&giveTopicFormat($topic));
 push(@properties,&isWrite($key,&giveWebName($topic),&Service::Editeur::giveTopicName($topic)));	
 return Service::Conversions::soap_array_string('proprietetopic',@properties);
 #return @properties;
}


# =========================
=pod

---+++ sameTopicParent($parent,$rep,$key ) ==> @list

| Description: | list of topics whose parent is $parent |
| Parameter: =$parent= | the parent topic, required, e.g. ="WebHome"= |
| Parameter: =$rep= | the Web where the search start, required, e.g. ="Main"= |
| Parameter: =$key= | the key to identifie the user, required, e.g. ="125"= |
| Return: =@list= | the list of topics whose parent is $parent,e.g.=("/Main/tutu.txt","/tata.txt")|

=cut
# -------------------------
#fonction qui renvoie tous les topics qui ont le meme topics parents donne en parametre
# 1 - je donne un topic en parametre (le topic parent)
# 2 - je retourne tous les topics qui ont le meme topic parent
sub sameTopicParent
{
  my $object = shift;
  my($parent,$rep,$key)=@_; 
  my $dest=$rep; 
  $rep="$TWiki::dataDir/$rep";   #modif ici j'ai enlever le /
  my @same;
  my $ret=0;
  
  #je recupere tous les topics correspondant
  if($parent eq "")
  {
	@same=&giveTopicsWeb($rep);
	$ret=1;
  }
  else
  {
	@same=&sameParent($parent,$rep,$key); #faut t'il gere le fait qu'il puisse y avaoir aussi $rep
	if($parent =~ /\./)
    {
		push(@same,&sameParent($',$rep,$key));
    }
    else
    {
		push(@same,&sameParent("$dest.$parent",$rep,$key));
    }
  }
    
  #je selectione les parents des enfants topics  
  my @true;
  foreach $titi (@same)
  {
    if($titi =~ /\n$/) 
    {
	  if(!($` =~ /,v/) )
      {
		
		$web=&giveWebName($`);
		$topic=&Service::Editeur::giveTopicName($`);
        if(&isView($key,$web,$topic))
        {
          my $topicName=&Service::Editeur::giveTopicName("$rep/$`"); # voir si il faut bien $rep ???
          my @taille=&sameParent($topicName,$rep,$key);
          push(@taille,&sameParent("$dest.$topicName",$rep,$key));
	      my $tlg=@taille;
  	      if($tlg>1)
  	      {
		    push(@true,"$`#");
	      }
	      else
	      {
		    push(@true,$`);
	      }
	    }
	  }
	}
	elsif($ret eq 1)
	{
	   my $topicName=&Service::Editeur::giveTopicName($titi);
	   my @taille=&sameParent($topicName,$rep,$key); #ainsi que ceux qui sont dans d'autre WEB
	   push(@taille,&sameParent("$dest.$topicName",$rep,$key));
	   my $tlg=@taille;
  	   if($tlg>1)
  	   {
		 push(@true,"$titi");
		 push(@orphelin,@taille); #je rajoute les enfants
		 push(@orphelin,"$titi"); #pour pas l'afficher deux fois
	   }
	 }
  } 
  
  
  #je rajoute dans true si param1==""  le topic sans parent
  if($ret eq 1)
  {
	#je gere les parents de parent
	undef %papa;
	for (@true) { $papa{$_} = 1 } 
	my $mama;
	print %papa;
	foreach $tata (@true)      #Pour chaque topic pere, , 
	{
		
	  $mama=&giveTopicParent("$rep/$tata"); #je regarde si son parent est dans la liste
	  #print "ici $mama\n";
	  if($mama =~ /\./)
		{
			print "ici2 $'";
			if($papa{"$'.txt"}>0)     #si oui, je l'enleve (pas le parent, le topic courant)  
			{
			  $papa{"$tata"}=0;
			}
		}
		if($papa{"$mama.txt"}>0)
		{
			$papa{"$tata"}=0;
		}	
	}
	  
	#je recupere les données validis
	my @space;
	foreach $tata (@true)
	{
		if($papa{$tata}>0)
		{
			push(@space,"$tata#");
		}
	}
	@true=@space;
  
  
  #je format orphelin pour lui permettre de faire des comparaison
  foreach $format (@orphelin)
  {
	$format=&Service::Editeur::giveTopicName($format).".txt";
  }
  
    #print "@orphelin\n";
	#je rajoute tous les enfants qui ne sont pas eu meme parent, et qui n'ont pas de parent.
    
    my @union = my @intersection = my @difference = ();
    my %count = ();
    my $element;
   
    foreach $element (@same, @orphelin) { $count{$element}++ }
    foreach $element (keys %count) 
    {
         push @union, $element;
         push @{ $count{$element} > 1 ? \@intersection : \@difference }, $element;
    }
 	push(@true,@difference);
    
  }
  
  @true=sort(@true);
  return Service::Conversions::soap_array_string("listeTop",@true);
  #return @true;
}



# =========================
=pod

---+++ giveWebProperties($web ) ==> $size

| Description: | give the properties of the Web |
| Parameter: =$web= | the web name, required, e.g. ="Main"= |
| Return: =$size= |the size of the Webs in octets,e.g.=(123574)|

=cut
# -------------------------
#retourne les proprietes d'un Web
sub giveWebProperties
{
 my $object = shift;
 return &listWebSize("$TWiki::dataDir/$_[0]");
}


# =========================
=pod

---+++ giveHierarchy($web,$key ) ==> @list

| Description: | give the list of topics and Webs which are in the Webs |
| Parameter: =$web= | the web name, required, e.g. ="Main"= |
| Parameter: =$key= | the key to identifie the user, required, e.g. ="125"= |
| Return: =@list= | the list of topics and Webs which are in the Webs,e.g. =("Web","toto.txt",)=|

=cut
# -------------------------
#renvoie la liste des sous web et des topic pour le chemin d'un Web donné.
sub giveHierarchy
{
 my $object = shift;	
 my ($web,$key)=@_;
 my @list;
 $web=$TWiki::dataDir."/".$web;
 my @webs=&giveSousWeb($web);
 my $nbWebs=@webs;
 if($nbWebs > 0)
 {
	push(@list,@webs);
 }
 else
 {
	push(@list,"");
 }
 push(@list,&getTopicName($web,$key));
 return Service::Conversions::soap_array_string("listeElem",@list);
 #return @list;
}

#test function
#fonction de test
sub sayHello
{
my $object = shift;
my $user=$_[0];
my $val="hello world from twiki by $user";
return $val;
}



1;
