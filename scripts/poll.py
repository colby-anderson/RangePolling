from heapq import heapify, heappush, heappop

example1 = [18, 50, 19, 52, 30]


prev_ballots = []
heap = []
heapify(heap)
distances = {}

def vote(ballot):
    if (len(prev_ballots) != 0):
        for p_ballot in prev_ballots:
            val = abs(ballot - p_ballot)
            heappush(heap, val)
            if val in distances:
                distances[val] = distances[val].append((p_ballot, ballot))
            else:
                distances[val] = [(p_ballot, ballot)]
    prev_ballots.append(ballot)

def mean2(v1, v2):
    return (v1 + v2) / 2

def mean(v1, w1, v2):
    return (v1 * w1 + v2) / (w1 + 1)

def tally():
    # debug above
    majority_not_found = True
    nums_to_group_nums = {}
    next_group_num = 1
    group_num_to_val = {}
    majority_threshold = len(prev_ballots) // 2
    if len(prev_ballots) % 2 > 0:
        majority_threshold = len(prev_ballots) // 2 + 1
    while majority_not_found:
        next = heappop(heap)
        for dist_pr in distances[next]:
            if dist_pr[0] not in nums_to_group_nums and dist_pr[1] not in nums_to_group_nums:
                nums_to_group_nums[dist_pr[0]] = [next_group_num]
                nums_to_group_nums[dist_pr[1]] = [next_group_num]
                group_num_to_val[next_group_num] = (mean2(dist_pr[0], dist_pr[1]), 2)
                next_group_num = next_group_num + 1
                if 2 >= majority_threshold:
                    return group_num_to_val[next_group_num][0]
            else:
                if dist_pr[0] not in nums_to_group_nums:
                    nums_to_group_nums[dist_pr[0]] = []
                if dist_pr[1] not in nums_to_group_nums:
                    nums_to_group_nums[dist_pr[1]] = []
                groupsA = nums_to_group_nums[dist_pr[0]]
                groupsB = nums_to_group_nums[dist_pr[1]]
                for group_num in groupsA:
                    if group_num not in groupsB:
                        group_num_to_val[group_num] = (mean(group_num_to_val[group_num][0], group_num_to_val[group_num][1], dist_pr[1]), group_num_to_val[group_num][1] + 1)
                    if group_num_to_val[group_num][1] >= majority_threshold:
                        return group_num_to_val[group_num][0]
                for group_num in groupsB:
                    if group_num not in groupsB:
                        group_num_to_val[group_num] = (mean(group_num_to_val[group_num][0], group_num_to_val[group_num][1], dist_pr[0]),group_num_to_val[group_num][1] + 1)
                    if group_num_to_val[group_num][1] >= majority_threshold:
                        return group_num_to_val[group_num][0]

def run_clustered_mean(ballots):
    for ballot in ballots:
        vote(ballot)
    return tally()

print(run_clustered_mean(example1))
