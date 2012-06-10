import json
import socket
import collections

rest = []
def find_data_bunch_with(content = u"world"):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(("94.45.239.235", 8080))

    def read_one_json_bunch(s):
        global rest
        bunches = rest + [""]

        while "\n\n" not in bunches[-1]:
            bunches.append(s.recv(1024))

            if len(bunches) > 5000:
                raise MemoryError("too much unfinished data.")

        pos = bunches[-1].find("\n\n")
        bunches[-1], rest = bunches[-1][:pos], [bunches[-1][pos+2:]]

        jsondata = "".join(bunches)

        one_state = json.loads(jsondata)
        return one_state

    state = {}
    while content not in state.keys():
        state = read_one_json_bunch(s)
    s.close()

    return state[content]

state = find_data_bunch_with()

players = {}
for data in state["players"]:
    players[data[u"id"]] = data[u"name"]

bases_per_player = collections.Counter()
ships_per_player = collections.Counter()
metal_per_player = collections.Counter()

def count_metal(entity):
    metal_per_player[entity[u"owner"]] += entity[u"contents"].count("R")

for base in state["bases"]:
    bases_per_player[base[u"owner"]] += 1
    count_metal(base)

for ship in state["ships"]:
    count_metal(ship)
    ships_per_player[ship[u"owner"]] += len(ship[u"contents"])

best_two_bases = bases_per_player.most_common(2)
best_two_ships = ships_per_player.most_common(2)
best_two_metal = metal_per_player.most_common(2)

def nameize((k, v)):
    return (players[k], v)

best_two_bases = map(nameize, best_two_bases)
best_two_ships = map(nameize, best_two_ships)
best_two_metal = map(nameize, best_two_metal)

with open("wpn_stats.json", "w") as jsfile:
    json.dump(dict(bases=best_two_bases, ships=best_two_ships, metal=best_two_metal), jsfile)
