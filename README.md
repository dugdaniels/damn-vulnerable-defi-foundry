My solutions to [Damn Vulnerable DeFi](https://www.damnvulnerabledefi.xyz) using [Nicolás García's](https://twitter.com/ngp2311) [Foundry setup](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry).

Working through the solutions currently. I'll update this README as I go.

- [x] Unstoppable
- [x] Naive receiver
- [x] Truster
- [x] Side Entrance
- [x] The Rewarder
- [x] Selfie
- [x] Compromised
- [x] Puppet
- [x] Puppet V2
- [x] Free Rider
- [ ] Backdoor
- [ ] Climber
- [ ] Wallet Mining
- [ ] Puppet V3
- [ ] ABI Smuggling

## How To Validate Solutions 🕹️

1.  **Install Foundry**

First run the command below to get foundryup, the Foundry toolchain installer:

``` bash
curl -L https://foundry.paradigm.xyz | bash
```

Then, in a new terminal session or after reloading your PATH, run it to get the latest forge and cast binaries:

``` console
foundryup
```
Advanced ways to use `foundryup`, and other documentation, can be found in the [foundryup package](./foundryup/README.md)

2. **Clone This Repo and install dependencies**
``` 
git clone https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry.git
cd damn-vulnerable-defi-foundry
forge install
```

3. **Run the exploit for a challenge**
```
make [CONTRACT_LEVEL_NAME]
```
or
```
./run.sh [LEVEL_FOLDER_NAME]
./run.sh [CHALLENGE_NUMBER]
./run.sh [4_FIRST_LETTER_OF_NAME] 
```