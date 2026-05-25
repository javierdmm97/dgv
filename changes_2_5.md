# 🗺️ Operación DGV - Changes before Phase III

Afer careful analysis we are going to:

1. Add a new phase before phase 4 (phase 4 is now phase 5)
2. Add a new phase 2.5 for some modifications of current implementations
3. Add a few fixes before continuing
4. Delete some tasks and move the priority of others 

---


## The new phase 4

One of the main changes is implementing a Firebase and a frontend.
This phase will probably suffer modifications in the future.

The firebase will have the data for: 

  - Players: license points, historical series of license points between rounds, current value measured in the app of alcohol,historical series of measurements, if he got a fine and how much, timestamp, the image of the profile, name and surname, unique_id.
  - Notifications: text, timestamp and status_notification (read, pending read).

The idea is we write this to Firebase so a frontend could display the leaderboard, show notifications on the top read from the notification table in Firebase (with the auto-reload web when a notification or change in the leaderboard is triggered).

In the app we can:

- send custom notifications: text and maybe image.
- predefined notifications: if someone is on streak, a new fine, predefined jokes-conditions to trigger a new notification... some events auto-send the notifications.
- one of the notifications is the MOAB: if someone is on a streak of being above the measurement, we send that as a MW joke/reference.

Sending notifications is just writting to the Table on the DB.

In the web:

- we see the leaderboard with a few of the stats we save.
- top 3 should have the medals on to see who is winning.
- on top we have the notifications (maybe 30s or 1 min on the screen and the next come. The timer can be seen because a line will go from left to right indicating how much time is left on screen)
- we can reproduce a few sounds for when we update the leaderboards or a new notification.
- show at the end the leaderboard, top 3 , the enviromental distinctives, the one with most dgt titles.
- 
The idea of this phase is critical but at the same time we need to make it in a way that if we do not have internet access the app will still work and we do not write to firebase.


## Phase 2.5

This phase is focusing in changes made to current code implementations that we want to modify:

- We no longer impound any vehicle/player: instead if you lose a lot of points (more than 4) you get a fine. Fines are -4 points and you lose money. Money is not related to this app, it is related to a game to be played the next day. You only need to know/track the money lost (for example -100).
- We have to correct the points given/lost in the measurements: the idea is to simplify (-4 -2 0 +2 +4). The max points are kept at 15.
- The winner is now only the top 3 of the leaderboard. We calculate that by who has more points in the license and to break the tie the system has to calculate the deviation of the line from the perfect sweet spot line and give us a number of perfection so we can see how close each player are to each other.
- Initial measurements still will give no feedback, no points and no titles.
- DGT Titles are now merely visual: we keep the logic but know is only useful for the phase 4 where at the end we show which person collected the most DGT Titles. This player do not win anything (and if he does, it will be money for the next day game).
- Two titles will change:  Vehículo Híbrido (Reading dropped -> this is impossible to happen in the span of 5 hours aprox) and ITV Passed ( Same reading twice). We are going to change ITV Passed to someone who lost points last round and now they are in the zone and Vehículo Híbrido to ....................................................
- Environmental Distinctive Badges are kept the same.
- Grand Prizes as we said is now just the Leaderboard. This is the only source of truth. The badge/title accumulation and the Environmental Distinctives are also there but more as a joke.
- if you are under the perfect line (the sweet spot) you should also lose points (maybe less , max -2 points -> we called this the "Policia de la Diversion").
- When you lose 4 points and you get a fine we show that. We have the image for that in assets\fine.png.
- We need a button to debug the app so we need a way to trigger the next measurement without waiting the 30/45/60 mins.

## Fixes

- We have to consider that if someone is going up and pass the sweet spot he is going to start losing points in all the following rounds (alcohol takes a lot more to drop i think). In here we have to consider that because it would make no sense to lose interest in round 3/4 because you are already above.
- The leaderboard do not update until we reload: this happened before because of the state updating but not reloading. After i close app or go out of leaderboard and comeback i can see the updates.


## Task deletion

A lot in phase 3 is implemented or partially implemented. But a lot if missing too: OCR, license viewing, having max rounds so we see the end,dgt title awarding and showing it in the license, player management... plus the new possible tasks we want to add.

### 3.2 Round-Robin Flow (“El Retén”)

This is partially implemented. This will need analysis to see what is done and what is not.
- Implement auto-advance every 10 seconds is getting deleted: we advance as we do right now: we input the measurement and once we say OK we continue to the next.

### Penalty System

This is partially or completely implemented. We are going to fully delete this.  (assets/msg_error.png) this is not even for this error and is already implemented.


### 3.4 DGT Title System

Partially implemented. 3 grand prizes got removed as we said above.

---

In phase four we are going to delete:

- Add share functionality (social media)
- Implement envelope animation for 3 Grand Prizes -> envelopes are only for the 5 enviromental distinctives.
- Add “Finish Game” button to main menu (visible if game in progress) this should move to phase 3 so we can start testing how to end the game. It is better this way instead of fixed rounds because we can end when we want.
- Check 4.4 BAC Progression Graphs because it could be already implemented.
- Add a visual mod step (4.10 or something) to change roundeness to be more boxy and to edit the font (to be selected).

The rest is perfect.

---
In Future Enhancements we have a lot to delete:

- Share leaderboard to social media
- QR code for quick player joining
- Multiplayer sync across devices (Firebase)
- Custom avatar upload
- Configurable checkpoint intervals
- Theme customization (colors, sounds)
- Custom BAC thresholds per player
- Achievement unlocking system
- Leaderboard across multiple games
- iOS support
- Bluetooth breathalyzer integration
- Real-time multiplayer with WebSockets

The rest are to be kept.

And the ones to be moved to other phases: 

- OS push notifications for checkpoint alerts (requires flutter_local_notifications + platform permissions) -> this is soooo critical. This needs to go up to 2.5 phase bc without notifications the player with the phone will not receive a notification and sound to know groups are to be measured. Sound: assets\sound\policia_control.mp3.
