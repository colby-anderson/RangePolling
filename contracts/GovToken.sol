pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GovToken is IERC20 {
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;
    mapping (address => mapping (address => uint256)) _locked;


    constructor(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
    }

    function totalSupply() public override view returns (uint) {
        return _supply;
    }
    function balanceOf(address src) override public view returns (uint) {
        return _balances[src];
    }
    function allowance(address src, address guy) override public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) override public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        override
        returns (bool)
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "ds-token-insufficient-approval");
            _approvals[src][msg.sender] = _approvals[src][msg.sender] - wad;
        }

        require(_balances[src] >= wad, "ds-token-insufficient-balance");
        _balances[src] = _balances[src] - wad;
        _balances[dst] = _balances[dst] - wad;

        return true;
    }

    function approve(address guy, uint wad) override public returns (bool) {
        _approvals[msg.sender][guy] = wad;
        return true;
    }

    function lock(address user, uint256 weight) external {
        require(_balances[user] >= weight + _locked[user][msg.sender]);
        _locked[user][msg.sender] += weight;
    }

    function unlock(address user, uint256 weight) external {
        _locked[user][msg.sender] -= weight;
    }

    function mint(uint wad) public {
        mint(msg.sender, wad);
    }
    function burn(uint wad) public {
        burn(msg.sender, wad);
    }
    function mint(address guy, uint wad) public {
        _balances[guy] = _balances[guy] + wad;
        _supply = _supply + wad;
    }
    function burn(address guy, uint wad) public {
        if (guy != msg.sender && _approvals[guy][msg.sender] != uint(-1)) {
            require(_approvals[guy][msg.sender] >= wad, "ds-token-insufficient-approval");
            _approvals[guy][msg.sender] = _approvals[guy][msg.sender] - wad;
        }

        require(_balances[guy] >= wad, "ds-token-insufficient-balance");
        _balances[guy] = _balances[guy] - wad;
        _supply = _supply - wad;
    }

}
