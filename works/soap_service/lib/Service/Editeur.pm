package Service::Editeur;

use Service::Arborescence;
use TWiki::Func;
use TWiki::Store;
use TWiki::Access;
use TWiki::Prefs;
use TWiki;
use Service::Conversions;
use TWiki::Attach;

# =========================
=pod

---+++ giveDateSeconds($topic ) ==> $date

| Description: | give the date of the topic |
| Parameter: =$topic= | the topic name, required, e.g. ="titi.txt"= |
| Return: =$date= | the date of the topic,e.g. =(45645)=|

=cut
# -------------------------
# retourne la date en nombre de secondes
sub giveDateSeconds
{
	my $date;
	open(FILE,$_[0]) || die "Erreur majeur, fichier non accessible" ;
	
	while(<FILE>)
	{
		if(/date="/)
		{
			$tmp=$';
			if($' =~ /"/)
			{
				$date=$`;
			}
		}
	}
	close(FILE);
	return $date;
}


# =========================
=pod

---+++ getData($topic ) ==> $data

| Description: | give the data of the topic |
| Parameter: =$topic= | the topic name, required, e.g. ="titi.txt"= |
| Return: =$data= | the data of the topic=|

=cut
# -------------------------
sub getData
{
  my $data;
  ($meta,$data)=TWiki::Store::readTopic($_[0],$_[1]);
  return $data;	
}

# =========================
=pod

---+++ getAttach($topic ) ==> @attach

this function doesn't work

=cut
# -------------------------
sub getAttach
{
 my @attach;
 push(@attach,"attache1");
 push(@attach,"attache2");
 return @attach;
}

# =========================
=pod

---+++ giveWebName( $path ) ==> $name

| Description: | get the name of the topic based of the path of the topic|
| Parameter: =$path= | the web path, required, e.g. ="Main/SubMain/toto.txt"= |
| Return: =$name= | the name of the topic based of the path of the topic ,e.g.="toto"|

=cut
# -------------------------
#renvoie le nom du topic sans le chemin, ni le .txt
sub giveTopicName
{
  my $name;
  my $temp;
  
  my @chaine=split("/",$_[0]);
  $temp=pop(@chaine);
  
  if($temp =~ /.txt/)
  {
	$name=$`;
  }
  return $name;
}

# =========================
=pod

---+++ getAttachPath($attach ) ==> $path

| Description: | give the path of the attach |
| Parameter: =$attach= | the attach name, required, e.g. ="video.avi"= |
| Return: =$path= | the path where the attachment is ,e.g. ="/pub/Main/video.avi"=|

=cut
# -------------------------
sub getAttachPath
{
  my $val;
  if( $_[0] =~ /path="/)
  {
	$tmp=$';
	if($' =~ /"/)
	  { 
		$val=$`;
	  }
  }
  return $val;	
}

# =========================
=pod

---+++ getAttachAttr($attach ) ==> $attr

| Description: | give the attribute of the attach |
| Parameter: =$attach= | the attach name, required, e.g. ="video.avi"= |
| Return: =$pattr= |  the attribute of the attach  |

=cut
# -------------------------
sub getAttachAttr
{
  my $val;
  if( $_[0] =~ /attr="/)
  {
	$tmp=$';
	if($' =~ /"/)
	  { 
		$val=$`;
	  }
  }
  return $val;	
}


# =========================
=pod

---+++ getAttachComment($attach ) ==> $comment

| Description: | give the comment of the attach |
| Parameter: =$attach= | the attach name, required, e.g. ="video.avi"= |
| Return: =$comment= |  the comment of the attach ,e.g. ="it's a great video"= |

=cut
# -------------------------
sub getAttachComment
{
  my $val;
  if( $_[0] =~ /comment="/)
  {
	$tmp=$';
	if($' =~ /"/)
	  { 
		$val=$`;
	  }
  }
  return $val;	

}

# =========================
=pod

---+++ getAttachDate($attach ) ==> $date

| Description: | give the date of the attach |
| Parameter: =$attach= | the attach name, required, e.g. ="video.avi"= |
| Return: =$date= |  the date of the attach in seconds ,e.g. ="546541"= |

=cut
# -------------------------
sub getAttachDate
{
  my $val;
  if( $_[0] =~ /date="/)
  {
	$tmp=$';
	if($' =~ /"/)
	  { 
		$val=$`;
	  }
  }
  return $val;	

}

# =========================
=pod

---+++ getAttachSize($attach ) ==> $size

| Description: | give the size of the attach |
| Parameter: =$attach= | the attach name, required, e.g. ="video.avi"= |
| Return: =$size= |  the size of the attach in octets ,e.g. ="456541"= |

=cut
# -------------------------
sub getAttachSize
{
  my $val;
  if( $_[0] =~ /size="/)
  {
	$tmp=$';
	if($' =~ /"/)
	  { 
		$val=$`;
	  }
  }
  return $val;	
}

# =========================
=pod

---+++ getAttachUser($attach ) ==> $user

| Description: | give the userName of the attach |
| Parameter: =$attach= | the attach name, required, e.g. ="video.avi"= |
| Return: =$user= |  the user name of the attach  ,e.g. ="guest"= |

=cut
# -------------------------
sub getAttachUser
{
  my $val;
  if( $_[0] =~ /user="/)
  {
	$tmp=$';
	if($' =~ /"/)
	  { 
		$val=$`;
	  }
  }
  return $val;	
}

# =========================
=pod

---+++ getAttachVersion($attach ) ==> $version

| Description: | give the version of the attach |
| Parameter: =$attach= | the attach name, required, e.g. ="video.avi"= |
| Return: =$version= |  the version of the attach  ,e.g. ="1.1"= |

=cut
# -------------------------
sub getAttachVersion
{
  my $val;
  if( $_[0] =~ /version="/)
  {
	$tmp=$';
	if($' =~ /"/)
	  { 
		$val=$`;
	  }
  }
  return $val;	
}

# =========================
=pod

---+++ canLock($key,$web,$topic) ==> $lock

| Description: | give the version of the attach |
| Parameter: =$topic= | the topic name, required, e.g. ="WebHome.txt"= |
| Parameter: =$web= | the Web name where the topic is, required, e.g. ="Main"= |
| Parameter: =$key= | the key to identifie the user, required, e.g. ="125"= |
| Return: =$lock= |  return 1 if the topic can be locked and lock it, 0 either  ,e.g. ="1"= |

=cut
# -------------------------
#lock le topic si c possible et renvoie 1 sinon renvoie 0
sub canLock
{
  my($key,$web,$topic)=@_;
  my $result=0;
  my $log=&Service::Connection::getLogin($key);
  $userName=&Service::Connection::initialize($log,$web,$topic);
  return &Service::Topics::lock($key,$log,$web,$topic,1);
}


############################
### Fonctions Web Serice ###
############################


# =========================
=pod

---+++ getTopic($path,$key) ==> %hash

| Description: | give the topic object which is located by the path  |
| Parameter: =$path= | the path, required, e.g. ="/main/toto.txt"= |
| Parameter: =$key= | the key to identifie the user, required, e.g. ="125"= |
| Return: =$hash= |  represent the object topic. All the proprties are null if the user haven't got the rights
                     ,e.g.=("WebName","topicName","author","date","format","version","parent","data")=  |

=cut
# -------------------------
# prend un chemin en parametre correspondant au topic
# return une table de hashage
# %hash -> {'version'}=nb
# %hash -> {'contenu'}= string
# %hash -> {'attach'}= @attachement
sub getTopic
{
	my $object = shift;
	my ($path,$key)=@_;
	$path="$TWiki::dataDir/$path";
	my $web=&Service::Arborescence::giveTopicPath($path);
	my $topic=&giveTopicName($path);
	if((&Service::Arborescence::isWrite($key,$web,$topic)>0) && (&canLock($key,$web,$topic)))
	{
	  my $author=&Service::Arborescence::giveTopicAutheur($path);
	  my $date=giveDateSeconds($path);
	  my $format=&Service::Arborescence::giveTopicFormat($path);
	  my $version=&Service::Arborescence::giveTopicVersion($path);
	  my $parent=&Service::Arborescence::giveTopicParent($path);
	  my $data=&getData($web,$topic);
	  %hash=('web'=>&Service::Arborescence::format($web),'topic'=>&Service::Arborescence::format($topic),'author'=> &Service::Arborescence::format($author),'date'=>$date,'format'=>&Service::Arborescence::format($format),'version'=>$version,'parent'=>&Service::Arborescence::format($parent),'data'=>&Service::Arborescence::format($data));
	}
	else
	{
	  %hash=('web'=>null,'topic'=>null,'author'=> null,'date'=>null,'format'=>null,'version'=>null,'parent'=>null,'data'=>null);
	}
	return Service::Conversions::soap_topic("topicpro",%hash);
	#return %hash;
}


# =========================
=pod

---+++  getAttach($topic,$file) ==> %hash

| Description: | give the attach object which is located by the path  |
| Parameter: =$topic= | the topic name, required, e.g. ="/main/toto.txt"= |
| Parameter: =$file= | the name of the file attachement, required, e.g. ="video.avi"= |
| Return: =$hash= |  represent the object attach. 
                     ,e.g.=("name","attribut","comment","date","size","path","user","version")=  |

=cut
# -------------------------
#pour un topic et un nom de fichier, renvoie les propriete de l'attachement
sub getAttach
{
	my $object = shift;
	
	my $text=TWiki::Func::readTopicText(Service::Arborescence::giveTopicPath($_[0]),&giveTopicName($_[0]));
	my $fic=$_[1];
	my %hash;
	
	my $name=$fic;
	my $attr;
	my $comment;
	my $date;
	my $size;
	my $path;
	my $user;
	my $version;

	if ( $text =~ /%META:FILEATTACHMENT{name=\"$fic([^}]*)}/o )
	{
	  
	  $attr = &getAttachAttr($&);
	  $comment = &getAttachComment($&);
	  $date = &getAttachDate($&);
	  $size = &getAttachSize($&);
	  $path = &getAttachPath($&);
	  $user = &getAttachUser($&);
	  $version = &getAttachVersion($&);
	}
	
	%hash=('name'=>$name,'attr'=>$attr,'comment'=> $comment,'date'=>$date,'size'=>$size,'path'=>$path,'user'=>$user,'version'=>$version);
	return Service::Conversions::soap_attach('propatt',%hash);
	#return %hash;
}



# =========================
=pod

---+++  getAllTopic($key) ==> @result

| Description: | give all the web.topic that user can access with the key  |
| Parameter: =$key= | the key to identifie the user, required, e.g. ="125"= |
| Return: =@result= | all the web.topic that user can access with the key  ,e.g.=(Main.toto,TWiki.titi)=  |

=cut
# -------------------------
#prend en parametre une clé et renvoie un tableau de chaine contenant les web.topic de tous le twiki
sub getAllTopic
{
	my $object = shift;
	my ($key)=@_;
	my @topics=&Service::Arborescence::giveTopicsPath("$TWiki::dataDir",$key);
	my @result;
	foreach $topic (@topics)
	{
		push(@result,&Service::Arborescence::giveWebName($topic).".".&giveTopicName($topic));
	}
	
	return Service::Conversions::soap_array_string('alltopweb',@result);
	#return @result;
}


# =========================
=pod

this Service doesn't work

=cut
# -------------------------
#prend une chaine de caracetre correpondant au code HTML et renvoie une chaine correspondant au code LaTex correspondant
sub getLaTex
{
	my $object = shift;
	my ($html)=@_;
	return "c du Latex";
}




# =========================
=pod

---+++  getListAttach($topic) ==> @result

| Description: | give the list of attach file for the topic  |
| Parameter: =$topic= | the topic name, required, e.g. ="/Main/toto.txt"= |
| Parameter: =$key= | the key to identifie the user, required, e.g. ="125"= |
| Return: =@result= |  the list of attach file for the topic ,e.g.=(/pub/Main/video.avi,/pub/TWiki/text.txt)=  |

=cut
# -------------------------
#renvoie la liste des attachements pour le chemin d'un topic donné
sub getListAttach
{
	my $object = shift;
	my ($rep,$key)=@_;
	my @attach;
	
	
	my $web=&Service::Arborescence::giveWebName($rep);
	my $topic=&giveTopicName($rep);
	if(&Service::Arborescence::isView($key,$web,$topic))
	{
	
	  open(FILE,"$TWiki::dataDir/$rep") || die "Erreur majeur, fichier non accessible" ;
	
      while(<FILE>)
	  {
		  if (/%META:FILEATTACHMENT{name=\"([^}]*)}/ )
		  {
		   	if($& =~ /name="/)
			{
				if($' =~ /"/)
				{
					push(@attach,$`);
				}
			}
		  }
	  }
	  close(FILE);
	}
	return Service::Conversions::soap_array_string('listeatt',@attach);
	#return @attach;
}

1;



