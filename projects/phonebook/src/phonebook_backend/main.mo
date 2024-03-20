// imports

import Map "mo:base/HashMap";
import Text "mo:base/Text";

// actor --> canister --> smart contract
actor PhoneBook {
  // Motoko --> type language
  type Name = Text;
  type Phone = Text;

  type Entry = {
    desc : Text;
    phone : Phone;
  };

  // variable
  // let --> immutable
  // var --> mutable
  let phonebook = Map.HashMap<Name, Entry>(0, Text.equal, Text.hash);

  // functions
  // update function
  public func insert(name : Name, entry : Entry) : async () {
    phonebook.put(name, entry);
  };

  // query function
  public query func lookup(name : Name) : async ?Entry {
    phonebook.get(name); // return phonebook.get(name);
  };
};
