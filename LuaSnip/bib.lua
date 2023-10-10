return {
  s("publisher",
   c(1, {
     fmt([[
     publisher={publisher},
     address={address},
     ]], {
      publisher = t("{Springer Berlin Heidelberg}"),
      address = t("{Berlin, Heidelberg}"),
    }),
    fmt([[
    publisher={publisher},
    address={address},
    ]], {
      publisher = t("{Association for Computing Machinery}"),
      address = t("{New York, NY, USA}"),
    }),
    fmt([[
    publisher={publisher},
    address={address},
    ]], {
      publisher = t("{Insitute of Electrical and Electronics Engineers}"),
      address = t("{Piscataway, NJ, USA}"),
    })
   })
  ),
  s("Spri", fmt([[
    publisher={publisher},
    address={address},
    ]], {
      publisher = t("{Springer Berlin Heidelberg}"),
      address = t("{Berlin, Heidelberg}"),
    })
  ),
  s("Acm", fmt([[
    publisher={publisher},
    address={address},
    ]], {
      publisher = t("{Association for Computing Machinery}"),
      address = t("{New York, NY, USA}"),
    })
  ),
  s("IEEE", fmt([[
    publisher={publisher},
    address={address},
    ]], {
      publisher = t("{Insitute of Electrical and Electronics Engineers}"),
      address = t("{Piscataway, NJ, USA}"),
    })
  ),
}
