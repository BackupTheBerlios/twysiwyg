package Service;

# Service Global Module & Requests Dispatcher
# Author : Maxime Lamure & Romain Raugi

use strict;
use TWiki;

use vars qw($endpoint $key_range $timeout $max_connections $subwebs $locks_refresh
            $admin_lock $allow_complete_remove $max_filelock_tries $clients_file
            $locks_file $admin_lock_file $trace_file $trace_mode $jnlpDir $updateTrash
            $allow_generate_trashID $trashID_separator $uploadDir $doNotLogChanges
            $contacts_file $super_admin_lock $notifications
            );

BEGIN {
  do "Service.cfg";
}

use Service::Trace;
use Service::FileLock;
use Service::AdminLock;
use Service::Locks;
use Service::Conversions;
use Service::Connection;
use Service::Refactoring;
use Service::Topics;
use Service::Arborescence;
use Service::Editeur;
use Service::Notification;
use Service::Notification::ConnectionEvent;
use Service::Notification::RefactoringEvent;
use Service::Notification::LockEvent;
use Service::Notification::TopicEvent;

# Web Services

sub connect {
  return &Service::Connection::connect(@_);
}

sub disconnect {
  return &Service::Connection::disconnect(@_);
}

sub ping {
  return &Service::Connection::ping(@_);
}

sub getUsers {
  return &Service::Connection::getUsers(@_);
}

sub subscribe {
  return &Service::Notification::subscribe(@_);
}

sub removeSubscription {
  return &Service::Notification::removeSubscription(@_);
}

sub setAdminLock {
  return &Service::Connection::setAdminLock(@_);
}

sub lockTopic {
  return &Service::Topics::lockTopic(@_);
}

sub setTopic {
  return &Service::Topics::setTopic(@_);
}

sub getWebs {
  return &Service::Topics::getWebs(@_);
}

sub renameTopic {
  return &Service::Refactoring::renameTopic(@_);
}

sub moveTopic {
  return &Service::Refactoring::moveTopic(@_);
}

sub removeTopic {
  return &Service::Refactoring::removeTopic(@_);
}

sub mergeTopics {
  return &Service::Refactoring::mergeTopics(@_);
}

sub copyTopic {
  return &Service::Refactoring::copyTopic(@_);
}

sub giveTopicProperties
{
  return &Service::Arborescence::giveTopicProperties(@_);
}

sub sameTopicParent
{
  return &Service::Arborescence::sameTopicParent(@_);
}

sub giveWebProperties
{
  return &Service::Arborescence::giveWebProperties(@_);
}

sub giveHierarchy
{
  return &Service::Arborescence::giveHierarchy(@_);
}

sub getTopic
{
  return &Service::Editeur::getTopic(@_);
}

sub getAttach
{
  return &Service::Editeur::getAttach(@_);
}

sub getListAttach
{
  return &Service::Editeur::getListAttach(@_);
}

sub getAllTopic
{
  return &Service::Editeur::getAllTopic(@_);
}

sub getLaTex
{
  return &Service::Editeur::getLaTex(@_);
}


1;