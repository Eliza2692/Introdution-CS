package eliza.alarcon.javaexample;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        List<Track> tracks = new ArrayList<>();
        tracks.add(new Track("mobile","Tomy"));
        tracks.add(new Track("web","Ryan"));
        tracks.add(new Track("Game","Conor"));

        List<String> students = Arrays.asList("Harry","Ron","Hermione");
        Map<String, Track>  assignemets = new HashMap<>();

        Random random = new Random();
        for (String student : students){
            int index = random.nextInt(tracks.size());
            assignemets.put(student, tracks.get(index));
        }

        for (Map.Entry<String, Track> entry: assignemets.entrySet()){
            Track track = entry.getValue();
            Log.d("cs50", entry.getKey() + " got " + track.getName() + " with "
                + track.getInstructor());
        }
    }
}