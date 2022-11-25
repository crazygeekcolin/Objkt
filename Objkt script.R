query MyQuery {
  event(
    where: {event_type: {_eq: "ask_purchase "}, fa_contract: {_eq: "KT1NVvPsNDChrLRH5K2cy6Sc9r1uuUwdiZQd"}}
    limit: 30
  ) {
    fa_contract
    id
    level
    event_type
    marketplace_event_type
  }
}

#test fa
{
  fa_contract
  id
  level
  event_type
  marketplace_event_type
  currency {
    fa_contract
  }
}
}