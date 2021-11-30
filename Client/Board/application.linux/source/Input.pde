public class Input {
  int seq;
  int value;
  int timeSinceTransmission;
  boolean ack = false;
  
  /**
  *  Constructor for input
  *  @param seqNum  interger indicating where in the order of inputs this one falls
  *  @param inputVal  integer indicating what keypress this input represents
  */
  Input(int seqNum, int inputVal) {
    seq = seqNum;
    value = inputVal;
  }
}
