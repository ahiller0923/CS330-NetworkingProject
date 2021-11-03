import java.util.concurrent.ThreadLocalRandom;

import processing.core.PVector;

public class Bonus {
	int size;
	PVector position;
	
	Bonus() {
		size = 10;
		position = new PVector((float)ThreadLocalRandom.current().nextInt(200, 801), (float)ThreadLocalRandom.current().nextInt(200, 801));
	}
}
