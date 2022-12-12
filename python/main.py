from mido import Message, MidiFile, MidiTrack
import numpy as np
import sys

np.set_printoptions(threshold=sys.maxsize)

mid = MidiFile('RFIYmidi.mid')
mid2 = MidiFile()
track2 = MidiTrack()
mid2.tracks.append(track2)

array1 = np.empty((0, 3), int)

for i, track in enumerate(mid.tracks):
  counter = 0
  for msg in track:
  
    if msg.type == 'note_on':

      # track2.append(msg)
      array1 = np.append(array1,
                         np.array([[msg.note, msg.velocity, msg.time]]),
                         axis=0)

result = []
channels = 5
for j in range(0, channels):
  result.append([])

index = 0

# for index in range(0, array1.shape[0] - 1):
while (index < array1.shape[0]-1):
  if (array1[index + 1][2] != 0):
    result[0].append(list(array1[index]))
    for j in range(1, channels):
      result[j].append([array1[index][0], 0, array1[index][2]])

    index += 1

  else:
    delay = array1[index][2]
    zero_counter = 0
    counter = 1
    while(counter < channels):
      if(array1[index+counter][2] == 0):
        zero_counter += 1
        counter+= 1
      else:
        counter += channels

    for zeros in range(0, zero_counter+1):
        result[zeros].append([array1[index+zeros][0], array1[index+zeros][1], delay])
    for zeroes in range(zero_counter+1, channels):
        result[zeroes].append([array1[index][0], 0, delay])
    index += (zero_counter+1)


for item in result:
  item.append(list(array1[array1.shape[0] - 1]))


  
file1 = open('array.txt', 'w')
file2 = open('triplets.txt', 'w')
for m in array1:
  file2.write(str(m))

for no in range(0, len(result)):
  file1.write("int chan" + str(no) + " [] = {")
  for item in result[no]:
    file1.write(str(item[0]) + ", " + str(item[1]) + ", " + str(item[2]) + ", ")

  file1.write("}; \n \n \n \n \n ")

file1.close()

