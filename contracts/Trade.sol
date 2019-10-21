/*Trade contract*/
pragma solidity ^0.5.0;
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract Trade {
  address platformOwner;
  IERC20 token;

  //regions
  mapping (uint => bool) public regions;

  //farmers
  struct farmer {
    uint region_id;
    uint land_size;
    uint curr_harvest_id;
  }
  mapping (address => farmer) public farmers;

  //middlemans
  mapping (address => bool) public middlemans;

  //rice mills
  mapping (address => bool) public ricemills;

  //harvests
  struct harvest {
    address farmer;
    uint price;
    uint prepayment;
    uint mill_price;
    address middleman;
    address ricemill;
    bool harvested;
  }
  mapping (uint => harvest) public harvests;
  uint next_harvest_id = 1;

  //financier
  address financier;

  constructor(address tokAddress) public{
    platformOwner = msg.sender;
    token = IERC20(tokAddress);
  }

  modifier platformOnly {
    require(
        msg.sender == platformOwner,
        "Only platform can call this function."
    );
    _;
  }

  modifier farmerOnly {
    require(
        farmers[msg.sender].region_id != 0,
        "Only farmers can call this function."
    );
    _;
  }

  modifier middlemanOnly {
    require(
        middlemans[msg.sender],
        "Only middlemans can call this function."
    );
    _;
  }

  modifier ricemillerOnly {
    require(
        ricemills[msg.sender],
        "Only ricemills can call this function."
    );
    _;
  }

  //platform fn----------------------
  function create_region(uint region_id) public platformOnly{
    require(region_id > 0);
    require(!regions[region_id]);

    regions[region_id] = true;
  }

  /*function set_token(address tokAddress) public platformOnly{
    token = IERC20(tokAddress);
  }*/

  function onboard_farmer(address farmer_addr, uint region_id, uint land_size) public platformOnly{
    require(farmer_addr != address(0));
    require(regions[region_id]);
    require(farmers[farmer_addr].region_id == 0);

    farmers[farmer_addr].region_id = region_id;
    farmers[farmer_addr].land_size = land_size;
  }

  //function adjust_region(address farmer_addr, uint region_id){}
  //function adjust_land_size(address farmer_addr, uint land_size){}

  function onboard_middleman(address middleman_addr) public platformOnly{
    require(middleman_addr != address(0));
    require(!middlemans[middleman_addr]);
    middlemans[middleman_addr] = true;
  }

  function onboard_ricemill(address ricemill_addr) public platformOnly{
    require(ricemill_addr != address(0));
    require(!ricemills[ricemill_addr]);
    ricemills[ricemill_addr] = true;
  }

  function trigger_close_bid() public platformOnly{
  }

  function unfreeze_dispute(uint harvest_id) public platformOnly{
  }

  //farmer fn---------------------------
  function new_harvest() public farmerOnly returns (uint){
    uint harvest_id = farmers[msg.sender].curr_harvest_id;
    if(harvest_id != 0){
      require(!harvests[harvest_id].harvested);
    }

    harvests[next_harvest_id] = harvest(
      msg.sender, //farmer
      0, //price
      0, //prepayment
      0, //mill_price
      address(0), //middleman
      address(0), //ricemill
      false //harvested
    );
    return next_harvest_id++;
  }

  function farmer_confirm_price(uint harvest_id, uint price) public farmerOnly{
    require(harvests[harvest_id].farmer == msg.sender);
    require(!harvests[harvest_id].harvested);
    require(price > 0);
    require(price > harvests[harvest_id].prepayment);

    harvests[harvest_id].price = price;
  }

  //middlemans
  function provide_prepayment(uint harvest_id, uint prepayment) public middlemanOnly{
    //FIXME currently any middleman and provide any amount of prepayment to farmer
    require(harvest_id < next_harvest_id);
    require(!harvests[harvest_id].harvested);
    require(harvests[harvest_id].prepayment == 0);

    //send prepayment to farmer
    harvests[harvest_id].prepayment = prepayment;
    harvests[harvest_id].middleman = msg.sender;
    require(token.transferFrom(msg.sender, harvests[harvest_id].farmer, prepayment));
  }

  function middleman_payment(uint harvest_id, uint price) public middlemanOnly{
    require(harvest_id < next_harvest_id);
    require(!harvests[harvest_id].harvested);
    require(harvests[harvest_id].price > 0);
    require(price == harvests[harvest_id].price);
    if(harvests[harvest_id].prepayment >= 0)
      require(harvests[harvest_id].middleman == msg.sender);

    //send payment to farmer, less prepayment
    harvests[harvest_id].harvested = true;
    harvests[harvest_id].middleman = msg.sender;
    require(token.transferFrom(msg.sender, harvests[harvest_id].farmer, price - harvests[harvest_id].prepayment));
  }

  function middleman_confirm_millprice(uint harvest_id, uint millprice) public middlemanOnly{
    require(harvests[harvest_id].middleman == msg.sender);
    require(harvests[harvest_id].harvested);
    require(millprice > 0);

    harvests[harvest_id].mill_price = millprice;
  }

  //rice miller fn
  function ricemiller_payment(uint harvest_id, uint millprice) public ricemillerOnly{
    require(harvest_id < next_harvest_id);
    require(harvests[harvest_id].harvested);
    require(harvests[harvest_id].ricemill == address(0));
    require(harvests[harvest_id].mill_price > 0);
    require(millprice == harvests[harvest_id].mill_price);
    //FIXME no confirmation on ricemill identity by middleman

    //send payment to milldeman
    harvests[harvest_id].ricemill = msg.sender;
    require(token.transferFrom(msg.sender, harvests[harvest_id].middleman, millprice));
  }

}
