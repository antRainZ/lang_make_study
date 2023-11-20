class Graph:
    def __init__(self) -> None:
        self.edge = []
        self.index = 0
        self.inorder=[]
        self.outorder=[]
        self.pre={}
        pass

    def add(self,assign: list):
        '''
        assign exp1, func, exp2, exp3
        '''
        self.edge.append(assign)
        self.outorder.append([])
        inorders = []
        for i in range(2,len(assign)):
            item = str(assign[i])
            if item.isdigit():
                continue
            if item not in self.pre:
                continue
                # raise("not define")
            inorders.append(self.pre[item])
            self.outorder[self.pre[item]].append(self.index)
        self.inorder.append(inorders)
        self.pre[str(assign[0])]=self.index
        self.index += 1
    
    def log(self):
        print('---------------------')
        print(self.edge)
        print(self.index)
        print(self.inorder)
        print(self.outorder)
        print(self.pre)
        print('---------------------')

    def topological_order(self):
        # self.log()
        inDegree = [0]*self.index
        point = []
        for i in range(self.index):
            inDegree[i] = len(self.inorder[i])
            if inDegree[i] == 0:
                point.append(i)
        
        stage = 1
        while len(point) !=0:
            print("stage{}:".format(stage))
            stage += 1
            new_point = []
            for i in point:
                print(self.edge[i])
                for j in self.outorder[i]:
                    inDegree[j]-=1
                    if inDegree[j] == 0:
                        new_point.append(j)
            print()
            point = new_point

g = Graph()
# g.add(['x','=','2'])
# g.add(['y','add','x','3'])
# g.add(['z','mul','x','2'])
# g.add(['w','add','z','y'])
# g.topological_order()

g.add(['BK','=','1'])

# for i in range(10):
#     for j in range(2**(10-i-1)-1):
#         g.add(['a[{}][{}]'.format(2**(i+1),j),'HomMin'
#               ,'a[{}][{}]'.format(2**(i+1),j)
#               ,'a[{}][{}]'.format(2**(i+1),j+2**i)])

for i in range(10):
    for j in range(2**(10-i-1)-1):
        g.add(['a[{}]'.format(2**(i+1)*j),'HomMin'
              ,'a[{}]'.format(2**(i+1)*j)
              ,'a[{}]'.format(2**(i+1)*j+2**i)])

g.topological_order()