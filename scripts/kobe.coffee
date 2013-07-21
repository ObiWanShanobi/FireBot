# Description:
#   Kobe quotes
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot kobe - Returns a Kobe quote.
#
# Author:
#   EvanDotPro


kobe = [
    "Everyting negative - pressure, challenges - is all an opportunity for me to rise."
    "I'll do whatever it takes to win games, whether it's sitting on a bench waving a towel, handing a cup of water to a teammate, or hitting the game-winning shot."
    "I don't want to be the next Michael Jordan, I only want to be Kobe Bryant."
    "These young guys are playing checkers. I'm out there playing chess."
    "I've played with IVs before, during and after games. I've played with a broken hand, a sprained ankle, a torn shoulder, a fractured tooth, a severed lip, and a knee the size of a softball. I don't miss 15 games because of a toe injury that everybody knows wasn't that serious in the first place."
    "When I have the chance to guard Michael Jordan, I want to guard him. I want him. It’s the ultimate challenge."
    "I’m not changing my game whatsoever. I take good shots, hit the open man when he’s there. I definitely don’t need advice on how to play my game."
    "I was just letting them fly … You know I don’t leave any bullets in the chamber."
    "Better learn not to talk to me. You shake the tree, a leopard’s gonna fall out."
    "I baptized him. I turned him into a defensive player."
    "Not bad for seventh best player in the league."
    "My kids call me Grumpy from the seven dwarfs."
    "You pump your own gas? Yeah I pump my own gas!"
    "I should get an assist for that. It's an intentional pass to oneself, so it's an assist. That way people can't say all I do is shoot."
    "He Jalen Rose’d me."
    "Man, I’ll talk to him. Just go out there and bust their ass. Show them what they’re missing."
    "He’s good, he’s getting the f*** outta the way."
    "It’s not like if you ask Dwight or if you ask myself, we don’t dislike each other at all. It’s not like when Shaq and I were feuding. We didn’t want to be around each other. With me and Dwight, that’s just not the situation. It’s not like we’re best friends either, but it’s a good understanding I think."
    "That’s kind of like, where are your balls at?"
    "They can all kiss my ass as I’m sure he feels the same way. If you score 138 points, you kind of have a license to tell people to f*** off."
    "I’m like Neo out this mother f***er."
    "Fear? Fear for what? Only thing I fear is bees. … I don’t f*** with bees, man. Other than that, I’m not afraid of nothing."
    "[Smush Parker is] the worst. He shouldn’t have been in the NBA but we were too cheap to pay for a point guard. So we let him walk on."
    "I'm not fading into the shadows. I'm not going anywhere. We're not going anywhere... I'm not going for that s***."
    "In the pressure situations. You can try to avoid contact, because you dont want to go to the FT line in those situations. Me, I enjoy it."
    "If I go out there and miss game winners, and people say, 'Kobe choked,' or 'Kobe is seven for whatever in pressure situations.' Well, f*** you."
    "I'll do whatever it takes to win games, whether it's sitting on a bench waving a towel, handing a cup of water to a teammate, or hitting the game-winning shot."
    "The guy said NBA players are one in a million, ... I said, 'Man, look, I'm going to be that one in a million."
    "Happy Leap Day! Enjoy it while it's here...because like a Kobe Bryant pass, it only occurs once every 4 years..."
]

module.exports = (robot) ->
  robot.respond /Kobe/i, (msg) ->
    msg.send msg.random kobe

