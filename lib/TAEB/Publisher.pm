#!/usr/bin/env perl
package TAEB::Publisher;
use TAEB::OO;

has queued_messages => (
    isa     => 'ArrayRef',
    default => sub { [] },
);

has delayed_messages => (
    isa     => 'ArrayRef',
    default => sub { [] },
);

has turn_messages => (
    isa     => 'HashRef[ArrayRef]',
    default => sub { {} },
);

sub update {
    my $self = shift;
    $self->tick_messages;
    $self->turn_messages;
    $self->send_messages;
}

sub enqueue_message {
    my $self = shift;
    my $msgname = shift;

    TAEB->debug("Queued message $msgname.");

    push @{ $self->queued_messages }, ["msg_$msgname", @_];
}

sub send_messages {
    my $self = shift;
    my @msgs = splice @{ $self->queued_messages };

    for (@msgs) {
        my $msgname = shift @$_;
        TAEB->debug("Dequeueing message $msgname.");

        # this list should not be hardcoded. instead, we should let anything
        # subscribe to messages
        for my $recipient (TAEB->senses, TAEB->personality, TAEB->inventory, TAEB->spells, TAEB->dungeon->cartographer, TAEB->action, TAEB->knowledge, "TAEB::Spoilers::Item::Artifact") {
            next unless $recipient;

            if ($recipient->can('send_message')) {
                $recipient->send_message($msgname, @$_);
            }
            elsif ($recipient->can($msgname)) {
                $recipient->$msgname(@$_)
            }
        }
    }
}

sub delay_message {
    my $self = shift;
    push @{ $self->delayed_messages }, [@_];
}

sub tick_messages {
    my $self = shift;

    for (my $i = 0; $i < @{ $self->delayed_messages }; ) {
        if (--$self->delayed_messages->[$i][0] == 0) {
            my (undef, $msg, @args) = @{ splice @{ $self->delayed_messages }, $i, 1 };
            $self->enqueue_message($msg => @args);
        }
        else {
            ++$i;
        }
    }
}

=head2 get_generic_response Paramhash -> Maybe Str

Don't use this.

=cut

sub get_generic_response {
    my $self = shift;
    my %args = (
        responders => [ TAEB->personality, TAEB->action ],
        @_,
    );

    for (my $i = 0; $i < @{ $args{sets} }; $i += 2) {
        my $matched = 0;
        my @captures;
        my ($re, $name) = @{ $args{sets} }[$i, $i + 1];

        for my $responder (@{ $args{responders} }) {
            next unless $responder;

            if (my $code = $responder->can("$args{method}_$name")) {
                if ($matched ||= @captures = $args{msg} =~ $re) {

                    my $response = $responder->$code(
                        @captures,
                        $args{msg},
                    );
                    next unless defined $response;

                    TAEB->debug(blessed($responder) . " is responding to $name.");
                    return $response;
                }
            }
        }
    }

    return;
}

=head2 get_exceptional_response Str -> Maybe Str

This is used to check all messages for exceptions. Such as not having an item
we expected to have.

If no response is given, C<undef> is returned.

=cut

sub get_exceptional_response {
    my $self = shift;
    my $msg  = shift;

    return $self->get_generic_response(
        msg    => $msg,
        sets   => \@TAEB::ScreenScraper::exceptions,
        method => "exception",
    );
}

=head2 get_response Str -> Maybe Str

This is used to check for and get a response to any known prompt on the top
line. Consulted are the personality and action.

If no response is given, C<undef> is returned.

=cut

sub get_response {
    my $self = shift;
    my $line = shift;

    return $self->get_generic_response(
        msg    => $line,
        sets   => \@TAEB::ScreenScraper::prompts,
        method => "respond",
    );
}

=head2 send_at_turn turn message args

Send the given message at the given turn.

=cut

sub send_at_turn {
    my $self = shift;
    my $turn = shift;

    push @{ $self->turn_messages->{$turn} }, [@_];
}

=head2 send_in_turns turn message args

Send the given message in the given number of turns.

=cut

sub send_in_turns {
    my $self = shift;
    my $turn = TAEB->turn + shift;
    $self->send_at_turn($turn, @_);
}

sub turn_messages {
    my $self = shift;
    my @messages = splice @{ $self->turn_messages->{TAEB->turn} || [] };

    for (@messages) {
        $self->enqueue_message(@$_);
    }

    delete $self->turn_messages->{TAEB->turn};
}

make_immutable;
no Moose;

1;

