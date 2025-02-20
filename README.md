## Crowd Funder Instantiator

**This is a permissionless smart contract which allows crowd funding 'campaings' to be instantiated and donated to.**

 I noticed that there are lots of crowd funding smart contract projects. So I made my own for fun, but I also noticed that the 'real deal' projects often had some sort of management team or token or some sort of KYC/login, or had a lengthy justification for their project. And I thought, I just want to see something that is permissionless and simple and just there to use. So here it is. Have at it.

- **Ethereum Mainnet Address**
```shell
$ n/a (deploy your own)
```
- **Arbitrum One Address**
```shell
0x0D5f00F25a7013cef02263F806e7A57508117893
```


### Feel free to deploy this on other EVM compatible chains. **

I have also developed a TUI which allows you to interact with any of these contracts, just by specifying the chain, rpc and contract address. The TUI as it stands takes a 0.3% fee on any transactions. This of course can be mitigated by developing your own interface. Or don't, if you want to support me ;) **

At some point I will integrate this with the Railgun ZK system for privacy. Privacy is a human right.
#### You can support me by donating to this address: 
```shell
0x64863c5b246aA8a2D3584B693Ece8F859f9a4F31
```
You can also support me by building your own permissionless, fault-tolerant economic infrastructure O_O

## The contract allows users to:

-   **create a campaign**,
-   **delete a campaign**,
-   **contribute to a campaign**,
-   **create a campaign**,
-   **claim a refund from a campaign if it is unsuccessful**,
-   **get the details of a campaign including refundable amounts**.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

