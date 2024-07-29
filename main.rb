filename = "words.txt"

raise StandardError, "words file not found!" unless File.exist? filename

words = File.open(filename, "r").readlines
puts words.length

filtered_words = words.filter { |word| word.length < 12 && word.length > 5}
puts filtered_words.length