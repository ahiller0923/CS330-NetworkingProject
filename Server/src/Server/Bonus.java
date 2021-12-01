package Server;
import java.util.concurrent.ThreadLocalRandom;

import processing.core.PVector;

public class Bonus {
	int size;
	PVector position;
	
	Bonus() {
		size = 5;
		position = new PVector((float)ThreadLocalRandom.current().nextInt(150, 600), (float)ThreadLocalRandom.current().nextInt(150, 600));
	}
}
