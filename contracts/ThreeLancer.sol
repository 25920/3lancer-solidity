// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract ThreeLancer {
    address public deployer;

    constructor() {
        deployer = msg.sender;
    }

    struct Service {
        string name;
        uint256 id;
        string description;
        uint256 fee;
        uint256 intervalInDays;
        string category;
        bool available;
        address[] pastBuyers;
    }

    struct Purchased {
        uint256 id;
        uint256 serviceId;
        address buyer;
        bool delivered;
    }

    struct Current {
        uint256 serviceId;
        bool done;
    }

    mapping (address => uint256[]) public okayServiceIds;
    mapping (address => bool) public verified;
    mapping (address => bool) public isRegistered;
    mapping (uint256 => Service) public services;
    mapping (uint256 => Purchased) public records;
    mapping (address => Current[]) public currency;
    uint256 public serviceAmount;
    uint256 public tradeAmount;
    uint256 public clientAmount;

    function changeFee(uint256 _id, uint256 _fee) public {
        require(msg.sender==deployer,"");
        Service storage service = services[_id];
        service.fee=_fee;
    }

    function getServiceBuyerRecords(uint256 _id) view public returns (address[] memory) {
        return services[_id].pastBuyers;
    }

    function verifyAnAddress(address _address,uint256[] memory _ids) public {
        require(msg.sender==deployer,"");
        require(deployer!=_address,"");
        verified[_address]=true;
        for (uint j=0;j<_ids.length;j++) {
            okayServiceIds[_address].push(_ids[j]);
        }
    }

    function getOkayIds(address _address) public view returns (uint256[] memory) {
        uint256[] memory okay = okayServiceIds[_address];
        return okay;
    }

    function deAvailable(uint256 _id) public {
        Service storage service = services[_id];
        service.available=false;
    }

    function createAnUserAccount() public returns (uint256) {
        require(isRegistered[msg.sender]==false,"");
        require(msg.sender!=deployer,"");
        isRegistered[msg.sender]=true;
        clientAmount+=1;
        return clientAmount-1;
    }

    function createServices(
        Service[] memory _services
    ) public returns (uint256) {
        require(msg.sender==deployer,"");
        for (uint y=0;y<_services.length;y++) {
            Service memory temp = _services[y];
            services[serviceAmount]=temp;
            serviceAmount+=1;
        }
        return serviceAmount-_services.length;
    }

    function checkCurrency(address _address) public view returns (uint256) {
        require(msg.sender==_address || msg.sender==deployer,"");
        Current[] memory allCurrent = currency[_address];
        uint256 h = 0;
        for (uint g=0;g<allCurrent.length;g++) {
            if (allCurrent[g].done==false) {
                h+=1;
            }
        }
        return h;
    }

    function updateCurrency(address _address, uint256 _id) public {
        require(msg.sender==_address,"");
        Current storage thisCurrent = currency[_address][_id];
        thisCurrent.done=true;
    }

    function buyAService(uint256 _id,uint256 _serviceIdOkay) public payable returns (uint256) {
        require(isRegistered[msg.sender]==true,"");
        require(verified[msg.sender]==true,"");
        bool k = false;
        uint256[] memory okays = getOkayIds(msg.sender);
        for (uint p=0;p<okays.length;p++) {
            if (okays[p] == _serviceIdOkay) {
                k  =true;
                break;
            } 
        }
        require(k==true,"");
        Service storage buyService = services[_id];
        Purchased storage record = records[tradeAmount];
        record.id=tradeAmount;
        Current memory current_mem = Current(buyService.id,false);
        currency[msg.sender].push(current_mem);
        buyService.pastBuyers.push(msg.sender);
        record.delivered=false;
        record.buyer=msg.sender;
        record.serviceId=buyService.id;
        tradeAmount+=1;
        require(msg.value==buyService.fee*50/100,"");
        payable(deployer).transfer(msg.value);
        return tradeAmount-1;
    }

    function paySecondHalfAllDone(uint256 _serviceId,uint256 _recordId,uint256 _sequence) public payable {
        require(isRegistered[msg.sender]==true,"");
        Service memory buyService = services[_serviceId];
        bool isThere = false;
        for (uint i = 0 ; i < buyService.pastBuyers.length;i++) {
            if (msg.sender==buyService.pastBuyers[i]) {
                isThere=true;
                break;
            }
        }
        require(isThere==true,"");
        Purchased storage record = records[_recordId];
        require(buyService.id==record.serviceId,"");
        require(msg.sender==record.buyer,"");
        require(record.delivered==false);
        record.delivered=true;
        require(msg.value==buyService.fee*50/100,"");
        payable(deployer).transfer(msg.value);
        updateCurrency(msg.sender, _sequence);
        uint256 number = checkCurrency(msg.sender);
        if (number > 0) {

        } else {
            verified[msg.sender]=false;//?
        }
    }

    function allAvailableService(
        ) public view returns (Service[] memory) {
        Service[] memory allEverCreated = new Service[](serviceAmount);
        for (uint i  =0;i<serviceAmount;i++) {
            Service memory item = services[i];
            if (item.available == true ) {
                allEverCreated[i]=item;
            }
        }
        if (allEverCreated.length == serviceAmount) {
            return allEverCreated;
        } else {
            Service[] memory left = new Service[](allEverCreated.length);
            for (uint i  =0;i<allEverCreated.length;i++) {
                left[i]=allEverCreated[i];
            }
            return left;
        }
    }

    function allService(
        ) public view returns (Service[] memory) {
        require(msg.sender==deployer,"");
        Service[] memory allEverCreated = new Service[](serviceAmount);
        for (uint i  =0;i<serviceAmount;i++) {
            Service memory item = services[i];
            allEverCreated[i]=item;
        }
        return allEverCreated;
    }

    function everyPurchasedData(
        ) public view returns (Purchased[] memory) {
        require(tradeAmount>0,"");
        Purchased[] memory allPurchase = new Purchased[](tradeAmount);
        for (uint i  =0;i<tradeAmount;i++) {
            Purchased memory record = records[i];
            allPurchase[i]=record;
        }
        return allPurchase;
    }
}