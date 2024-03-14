from operator import index
import pandas as pd
def read_file(file):
    df = pd.read_csv(file, sep='|', encoding='utf-16')    
    df.columns = ['result', 'order type', "entry", 'sl', 'tp', 'start date', 'end date','extra1','extra2','extra3','extra4']
    result_list = df['result'].tolist()
    return result_list
modified_file = read_file('4_Moving_Average_all_signal.txt')
print(modified_file)

def count_consecutive_losses(results):
    consecutive_losses = {'1': 0, '2': 0, '3': 0, '4': 0, 'extra':0}
    current_streak = 0
    for i in range(len(results)):
        if results[i] == 2:
            current_streak += 1
            if current_streak <= 4 and i < len(results) - 1 and results[i + 1] == 1: 
                consecutive_losses[str(current_streak)] += 1
            elif current_streak >4 and i < len(results) - 1 and results[i + 1] == 1:
                consecutive_losses['extra'] +=1
        else:
            current_streak = 0
    return consecutive_losses

test = [1, 1, 2, 2, 2, 2,2,2,2 ,1, 1, 2, 2, 2, 1, 1, 2, 2, 2, 1, 2,2]

# consecutive_losses = count_consecutive_losses(modified_file)



consecutive_commands = str(input("Nhập chuỗi lệnh muốn tìm: "))
following_commands = int(input("Nhập số lệnh tiếp theo muốn kiểm tra: "))


def find_consecutive_command(file, command_string, num_commands):
    my_list = [int(char) for char in str(command_string)]
    count = 0
    risk = -1
    reward = 1
    results = []
    def is_in_results(rr, results):
            for result in results:
                if result['RR'] == rr:
                    return True
            return False
    for i in range(len(file)):
        if file[i:i + len(my_list)] == my_list and i < len(file) - len(my_list):
            following_list = file[i + len(my_list):i + len(my_list) + num_commands]
            rr_ratio = sum(reward if num == 1 else risk for num in following_list)
            if is_in_results(rr_ratio, results):
                index = next((index for index, item in enumerate(results) if item["RR"] == rr_ratio), None)
                results[index]['soLantimDuoc'] += 1
            else:
                count = 1
                results.append({'soLantimDuoc': count, 'RR': rr_ratio})
    return results

test2 = [1, 1, 2, 2, 1, 1,1,2,1,2,2,1,2,2 ,1,1]

output = find_consecutive_command(test2, consecutive_commands, following_commands)

print(output)

# tìm kết quả của một chuỗi lệnh bất kì khi gặp: 
# input1: chuỗi lệnh, 21212122112 |||| xog cái kia thì làm cái này check trong 10 lệnh trước đó RR bằng -10
# input2: số lệnh muốn kiểm tra 
#  trả về 1
# [{soLantimDuoc: 2, RR: -3}, {soLantimDuoc: 2, RR: -3}]
# trả về 2
# [{soLantimDuoc: 2, RR: -1}, {soLantimDuoc: 2, RR: 1}]
