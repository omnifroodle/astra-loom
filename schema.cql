# current messages
create table messages (
    thread text,
    user text,
    id timeuuid,
    added timestamp,
    message text,
    picture text,
    primary key (thread, id, user)
);


create table threads_by_person (
    person text,
    thread text,
    active boolean,
    primary key (person, thread)
);

# future messages with better partitioning
create table messages_by_block_and_thread (
    thread text,
    block text,  // usually a day, assumes a reasonable sort
    id timeuuid,
    added timestamp,
    user text,
    message text,
    icon text,
    primary key ((block, thread), id, user)
);  // need a TTL here?


create table active_blocks (
    thread text,
    block text,
    primary key (thread, block)
);  // need a TTL here?