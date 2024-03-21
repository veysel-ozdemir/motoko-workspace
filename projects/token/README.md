# Token Project

## Overview

Token is a canister that can transfer ICRC-1 tokens from its account to other accounts. It is an example of a canister that uses an ICRC-1 ledger canister. Sample code can be found in this folder.

## Architecture

The sample code revolves around one core transfer function which takes as input the amount of tokens to transfer, the `Account` to which to transfer tokens and returns either success or an error in case e.g. the token transfer canister doesn’t have enough tokens to do the transfer. In case of success, a unique identifier of the transaction is returned.

This sample will use the Motoko variant.

## Prerequisites

This example requires an installation of:

-   [x] Install the [IC SDK](https://internetcomputer.org/docs/current/developer-docs/setup/install/index.mdx).
-   [x] Download and install [git](https://git-scm.com/downloads).

## How to get there

The following steps will guide you through the process of setting up the token canister for your own project.

### Step 1: Create a new `dfx` project and navigate into the project's directory.

```bash
dfx new --type=motoko token --no-frontend
cd token
```

### Step 2: Configure the `dfx.json` file to use the ledger :

```json
{
    "canisters": {
        "token_backend": {
            "main": "src/token_backend/main.mo",
            "type": "motoko",
            "dependencies": ["icrc1_ledger_canister"]
        },
        "icrc1_ledger_canister": {
            "type": "custom",
            "candid": "https://raw.githubusercontent.com/dfinity/ic/d87954601e4b22972899e9957e800406a0a6b929/rs/rosetta-api/icrc1/ledger/ledger.did",
            "wasm": "https://download.dfinity.systems/ic/d87954601e4b22972899e9957e800406a0a6b929/canisters/ic-icrc1-ledger.wasm.gz"
        }
    },
    "defaults": {
        "build": {
            "args": "",
            "packtool": ""
        }
    },
    "output_env_file": ".env",
    "version": 1
}
```

### Step 3: Prepare the token canister:

Replace the contents of the `src/token_backend/main.mo` file with the following:

```motoko
import Icrc1Ledger "canister:icrc1_ledger_canister";
import Debug "mo:base/Debug";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Blob "mo:base/Blob";
import Error "mo:base/Error";

actor {

  type Account = {
    owner : Principal;
    subaccount : ?[Nat8];
  };

  type TransferArgs = {
    amount : Nat;
    toAccount : Account;
  };

  public shared ({ caller }) func transfer(args : TransferArgs) : async Result.Result<Icrc1Ledger.BlockIndex, Text> {
    Debug.print(
      "Transferring "
      # debug_show (args.amount)
      # " tokens to account"
      # debug_show (args.toAccount)
    );

    let transferArgs : Icrc1Ledger.TransferArgs = {
      // can be used to distinguish between transactions
      memory = null;
      // the amount we want to transfer
      amount = args.amount;
      // we want to transfer tokens from the default subaccount of the canister
      from_subaccount = null;
      // if not specified, the default fee for the canister is used
      fee = null;
      // we take the principal and subaccount from the arguments and convert them into an account identifier
      to = args.toAccount;
      // a timestamp indicating when the transaction was created by the caller; if it is not specified by the caller then this is set to the current ICP time
      created_at_time = null;
    };

    try {
      // initiate the transfer
      let transferResult = await Icrc1Ledger.icrc1_transfer(transferArgs);

      // check if the transfer was successfull
      switch (transferResult) {
        case (#Err(transferError)) {
          return #err("Couldn't transfer funds:\n" # debug_show (transferError));
        };
        case (#Ok(blockIndex)) { return #ok blockIndex };
      };
    } catch (error : Error) {
      // catch any errors that might occur during the transfer
      return #err("Reject message: " # Error.message(error));
    };
  };
};

```

### Step 4: Start a local replica:

```bash
dfx start --background --clean
```

### Step 5: Create a new identity that will work as a minting account:

```bash
dfx identity new minter --storage-mode plaintext
dfx identity use minter
export MINTER=$(dfx identity get-principal)
```

> Transfers from the minting account will create Mint transactions. Transfers to the minting account will create Burn transactions.

### Step 6: Switch back to your default identity and record its principal to mint an initial balance to when deploying the ledger:

```bash
dfx identity use default
export DEFAULT=$(dfx identity get-principal)
```

### Step 7: Deploy the ICRC-1 ledger locally:

Take a moment to read the details of the call made below. Not only are you deploying an ICRC-1 ledger canister, you are also:

-   Setting the minting account to the principal you saved in a previous step (`MINTER`)
-   Minting 100 tokens to the DEFAULT principal
-   Setting the transfer fee to 0.0001 tokens
-   Naming the token Local ICRC1 / L-ICRC1

```bash
dfx deploy icrc1_ledger_canister --argument "(variant { Init =
record {
     token_symbol = \"ICRC1\";
     token_name = \"L-ICRC1\";
     minting_account = record { owner = principal \"${MINTER}\" };
     transfer_fee = 10_000;
     metadata = vec {};
     initial_balances = vec { record { record { owner = principal \"${DEFAULT}\"; }; 10_000_000_000; }; };
     archive_options = record {
         num_blocks_to_archive = 1000;
         trigger_threshold = 2000;
         controller_id = principal \"${MINTER}\";
     };
 }
})"
```

If successful, the output should be:

```bash
Deployed canisters.
URLs:
  Backend canister via Candid interface:
    icrc1_ledger_canister: http://127.0.0.1:4943/?canisterId=bnz7o-iuaaa-aaaaa-qaaaa-cai&id=mxzaz-hqaaa-aaaar-qaada-cai
```


### Step 8: Test on CandidUI:
After deploying ICRC-1 ledger locally, a link should be provided. By following the link, you will be able to test the canister on the CandidUI.

## Additions

> You can read more about how to setup the ICRC-1 ledger locally [here](https://internetcomputer.org/docs/current/developer-docs/defi/icrc-1/icrc1-ledger-setup).

## Reference
> The official GitHub repository of the token transfer project is available [here](https://github.com/dfinity/examples/tree/master/motoko/token_transfer).