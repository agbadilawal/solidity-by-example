const Escrow = artifacts.require("Escrow");

//this function is used to test for errors
const assertError = async (promise, error) => {
  try {
    await promise;
  } catch (e) {
    assert(e.message.includes(error));
    return;
  }
  assert(false);
};

contract("Escrow", (accounts) => {
  let escrow = null;
  const [arbiter, payer, recipient] = accounts; //destructures and assigns addresses to the names as they appear in the array
  before(async () => {
    escrow = await Escrow.deployed();
  });

  it("should deposit", async () => {
    await escrow.deposit({ from: payer, value: 900 }); //this is to test the deposit function of the contract by sending it 900 wei
    const escrowBalance = parseInt(await web3.eth.getBalance(escrow.address)); //parses the balance of the contract into an integer
    assert(escrowBalance === 900);
  });

  it("should NOT deposit if transfer exceed total escrow amount", async () => {
    assertError(
      escrow.deposit({ from: payer, value: 2000 }),
      "Cant send more than escrow amount"
    ); //this checks an attempt to send more than the stated amount fails
  });

  it("should NOT deposit if not sending from payer", async () => {
    assertError(
      escrow.deposit({ from: accounts[5], value: 100 }),
      "Sender must be the payer"
    ); //this should pass if the test fails ie. if the function requirements are not met in this case it refuses the payment since the sender is not the payer
  });

  it("should NOT release if full amount not received", async () => {
    assertError(
      escrow.release({ from: arbiter }),
      "cannot release funds before full amount is sent"
    ); //checks that funds are not released before the full amount is sent
  });

  it("should NOT release if not arbiter", async () => {
    await escrow.deposit({ from: payer, value: 100 }); //We are missing 100 wei
    assertError(
      escrow.release({ from: payer }),
      "only arbiter can release funds"
    ); //checks that only the arbiter should be able to release funds
  });

  it("should release", async () => {
    const initialRecipientBalance = web3.utils.toBN(
      await web3.eth.getBalance(recipient)
    ); //gets balance of the reciepient before release
    await escrow.release({ from: arbiter }); //arbiter calls release()
    const finalRecipientBalance = web3.utils.toBN(
      await web3.eth.getBalance(recipient)
    ); //gets balance of the recipient after release
    assert(
      finalRecipientBalance.sub(initialRecipientBalance).toNumber() === 1000
    );
  });
});
