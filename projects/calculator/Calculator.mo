// calculator project

// canister (smart contract)
actor {
    // var : mutable
    // let : immutable
    var cell : Int = 0;

    public func addition(num : Int) : async Int {
        cell += num;
        cell;
    };

    public func subtraction(num : Int) : async Int {
        cell -= num;
        cell;
    };

    public func multiplication(num : Int) : async Int {
        cell *= num;
        cell;
    };

    public func division(num : Int) : async ?Int {
        if (num == 0) {
            null;
        } else {
            cell /= num;
            ?cell;
        };
    };

    public func clear() : async () {
        cell := 0;
    };
};
