dofile("sys/lua/utf8.lua")--使用中文转码
parse("mp_infammo 1")--无尽

hero={0,0,0,0,0,0,0}
boss={0,0,0,0}
spy={0,0,0,0}
choose={0,0,0,0}--种类选择
fix={0,0,0,0}
player_num={}
num=0
if_death=0--死亡判定
death_num=0
sleep_f=0

---------------------------------------------------

function equip_boss(who,n_choose)--武器给予
    if(n_choose==1)then
        image("gfx/SkinsMenu/super-tank.png", 1, 1, 200 + who)--给他贴图
        parse('setmaxhealth '..who..' '..250)
        parse('sethealth '..who..' '..250)
        parse('equip '..who..' 81')--装甲
        parse('equip '..who..' 48')--炮火
        parse('equip '..who..' 90')--机炮
        parse('speedmod '..who..' -5')--移动速度减缓
        msg2(who,'\169000000255你是苏维埃最后的战甲@C')
        msg2(who,'\169000000255你拥有强大的火力和坚固的装甲@C')
        msg2(who,'\169000000255现在，夺回我们的人质！@C')
    end
    if(n_choose==2)then
        image("gfx/SkinsMenu/sun-king.png", 1, 1, 200 + who)--给他贴图
        parse('setmaxhealth '..who..' '..250)
        parse('sethealth '..who..' '..250)
        parse('equip '..who..' 84')--隐身
        parse('equip '..who..' 45')--激光
        parse('speedmod '..who..' 20')--高速
        msg2(who,'\169000000255你是日冕@C')
        msg2(who,'\169000000255你拥有强大的机动力和毁灭性的光耀@C')
        msg2(who,'\169000000255现在，夺回我们的人质！@C')
        fix[1]=2
    end
end
function omit_if(race,who)--冲突判断
    if(race==1)then--BOSS
        for if_i=1,4,1 do--单阵营最大人数(4人)
            if((if_i~=who or boss[who]==boss[if_i]) or boss[who]==spy[if_i] or boss[who]==hero[if_i])then
                return false
            end
        end
    elseif(race==2)then--HERO
        for if_i=1,4,1 do--单阵营最大人数(4人)
            if((if_i~=who and hero[who]==hero[if_i]) or hero[who]==spy[if_i] or hero[who]==boss[if_i])then
                return false
            end
        end
    elseif(race==3)then--SPY
        for if_i=1,4,1 do--单阵营最大人数(4人)
            if((if_i~=who and spy[who]==spy[if_i]) or spy[who]==boss[if_i] or spy[who]==hero[if_i])then
                return false
            end
        end
    end
    return true
end
function random(race,who)--随机
    --[[
    race:
        1:boss
        2:hero
        3:spy
    ]]
    if(race==1)then
        boss[who]=player_num[math.random(1,num)]
    elseif(race==2)then
        hero[who]=player_num[math.random(1,num)]
    elseif(race==3)then
        spy[who]=player_num[math.random(1,num)]
    end
end

------------------------------------------------------

addhook("startround_prespawn","prepare_r")--准备开始
function prepare_r()

end

addhook("startround","start_r")
function start_r()
    choose={0,0,0}--种类选择
    fix={0,0,0}--修理

    death_num=25-num--重置复活人数

    print(player(boss[1],"name"))
    print(player(boss[2],"name"))

    i=0
    if(num~=0)then
        while(i<=32)do--删除所有玩家的图像
            if(player(i,'exists')==true)then
                freeimage(i)
            end
            i=i+1
        end

        ii=0
        while(ii<=32)do--修改所有速度
            if(player(ii,'exists')==true)then
                parse('speedmod '..ii..' 5')
                parse('setmaxhealth '..ii..' 100')
            end
            ii=ii+1
        end

    -------------------------------------------

        if(boss[1]~=0)then--1号boss分配
            choose[1]=math.random(1,2)--选择随机数
            --1号及其2号boss选择（玩家1）
            equip_boss(boss[1],choose[1])
        end

        if(boss[2]~=0)then--2号boss分配
            if(choose[1]==1)then
                choose[2]=2
            elseif(choose[1]==2)then
                choose[2]=1
            end
            --1号及其2号boss选择（玩家2）
            equip_boss(boss[2],choose[2])
        end
    end

-------------------------------------------

    if(num~=0)then
        --1号英雄固有装备
        if(hero[1]~=0)then
            parse('equip '..hero[1]..' 79')--轻质护甲
            parse('equip '..hero[1]..' 74')--扳手
            parse('equip '..hero[1]..' 85')--电锯
            parse('equip '..hero[1]..' 77')--地雷
            parse('equip '..hero[1]..' 87')--激光地雷
            msg2(hero[1],'\169000000255你是工程师，善用你的扳手，你是胜利的关键@C')
        end

        --2号英雄固有装备
        if(hero[2]~=0)then
            parse('setmaxhealth '..hero[2]..' 50')--血量上限设置
            parse('equip '..hero[2]..' 82')--医疗护甲
            parse('equip '..hero[2]..' 91')--步枪
            parse('equip '..hero[2]..' 88')--传送枪
            msg2(hero[2],'\169000000255你是时空兵，使用你灵活的传送，躲避攻击@C')
        end

        --3号英雄固有装备
        if(hero[3]~=0)then
            parse('setmaxhealth '..hero[3]..' 120')--血量上限设置
            parse('sethealth '..hero[3]..' '..'1200')
            parse('equip '..hero[3]..' 80')--护甲
            parse('equip '..hero[3]..' 73')--燃烧瓶
            parse('equip '..hero[3]..' 51')--手榴弹
            parse('equip '..hero[3]..' 52')--闪光弹
            parse('equip '..hero[3]..' 54')--照明弹
            parse('equip '..hero[3]..' 72')--毒气弹
            parse('equip '..hero[3]..' 76')--飞机支援
            parse('equip '..hero[3]..' 89')--遥控炸弹
            parse('equip '..hero[3]..' 35')--狙击枪
            parse('equip '..hero[3]..' 30')--步枪
            parse('equip '..hero[3]..' 41')--防爆盾
            parse('equip '..hero[3]..' 46')--火焰喷射器
            msg2(hero[3],'\169000000255你是精英兵，你拥有多样的武器，使用他们进行高输出@C')
        end

        --4号英雄固有装备
        if(hero[4]~=0)then
            parse('equip '..hero[4]..' 52')--闪光弹
            parse('equip '..hero[4]..' 80')--护甲
            msg2(hero[4],'\169000000255你是闪光悍匪，你身上有无穷无尽的闪光弹@C')
        end

        --1号间谍固有装备
        if(spy[1]~=0)then
            parse('equip '..spy[1]..' 73')--燃烧瓶
            parse('equip '..spy[1]..' 80')--护甲
            msg2(spy[1],'\169000000255你是爆破警察，你身上有无穷无尽的炸弹@C')
        end

        if_death=1--开始判断
    end
end

addhook("endround","end_t")
function end_t()
    death_num=0--T剩余人数归零
    if_death=0--停止判定
    timer(2000,"end_r")
end

function end_r()
    fix={0,0}
    hero={0,0,0,0,0,0,0}
    boss={0,0,0}
    spy={0,0}


    --获取玩家的ID表
    i=0
    ii=0
    while(i<=32)do
        if(player(i,"exists")==true)then
            ii=ii+1
            player_num[ii]=i
        end
        i=i+1
    end

    num=ii

    --死亡抽取
    if(num~=0)then
        for xh=1,num,1 do
            if(3<=xh<=6)then
                random(2,(xh-2))
                if(omit_if(2,(xh-2)))then
                    random(2,(xh-2))
                end
            elseif(xh==2)then
                random(1,1)
                if(omit_if(1,1))then
                    random(1,1)
                end
            elseif(xh==7)then
                random(1,2)
                if(omit_if(1,2))then
                    random(1,2)
                end
            elseif(xh==8)then
                random(3,1)
                if(omit_if(3,1))then
                    random(3,1)
                end
            end
        end


        i=0
        while(i<=32)do--队伍的分配
            if(i==boss[1] or i==boss[2] or i==spy[1])then
                if(player(i,'exists')==true)then
                    parse('killplayer '..i)
                    parse('makect '..i)
                end
            elseif(i~=boss[1] and i~=boss[2] and i~=spy[1])then
                if(player(i,'exists')==true)then
                    parse('killplayer '..i)
                    parse('maket '..i)
                end
            end
            i=i+1
        end

        if(boss[1]~=0)then
            msg("\169255000000警告:"..player(boss[1],'name')..'是BOSS！@C')
            if(boss[2]~=0)then
                msg("\169255000000警告:"..player(boss[2],'name')..'是BOSS！@C')
            end
        end
    end
end

addhook('die','death')--已故之人——逝者之歌
function death(victim)
    if(victim~=nil)then
        tpa=1

        if(if_death==1)then
            if(victim==hero[1])then
                hero[1]=0
                msg("工程师已阵亡！")
            end
            if(victim==hero[2])then
                hero[2]=0
                msg("时空兵已阵亡！")
            end
            if(victim==hero[3])then
                hero[3]=0
                msg("精英兵已阵亡！")
            end
            if(victim==hero[4])then
                hero[4]=0
                msg("闪光兵已阵亡！")
            end
        end

        tpa=math.random(1,3)
        if(player(victim,'team')==1 and death_num~=0)then
            if(tpa==1)then
                parse('spawnplayer '..victim..' 80'..' 800')
            end
            if(tpa==2)then
                parse('spawnplayer '..victim..' 900'..' 200')
            end
            if(tpa==3)then
                parse('spawnplayer '..victim..' 1100'..' 850')
            end
            death_num=death_num-1
            msg2(victim,"你已被复活!@C")
            parse('equip '..victim..' 50')
            parse('equip '..victim..' 30')
        end

        if(#player(0,'team1living')~=0)then
            msg("恐怖分子剩余人数:"..(#player(0,'team1living')+death_num).."人@C")
        end

        --禁止机甲掉落装备
        if(player(boss[1],"exists")==true)then
            if(victim==boss[1])then
                return 1
            end
        end

        if(player(boss[2],"exists")==true)then
            if(victim==boss[2])then
                return 1
            end
        end
    end
end

addhook ("second","war")
function war()

    i2=1
    iii=0
    while(i2<=32)do--对人类
        if(player(i2,'exists')==true)then
            if(i2~=boss[1] and i2~=boss[2])then
                parse('setmoney '..i2..' 16000')
                parse('speedmod '..i2..' 5')
                if(i2==hero[1])then--英雄1的补给
                    parse('equip '..hero[1]..' 79')
                end
                if(i2==hero[2])then--英雄2的补给
                    parse('equip '..hero[2]..' 82')
                    parse('setmaxhealth '..hero[2]..' 50')--血量上限设置
                end
                if(i2==hero[3])then--英雄3的补给
                    parse('equip '..hero[3]..' 80')
                end
                if(i2==hero[4])then--英雄4的补给
                    parse('equip '..hero[4]..' 80')--护甲
                    iii=iii+1
                    if(iii==6)then
                        parse('equip '..hero[4]..' 52')--闪光弹
                        iii=0
                    end
                end
                if(i2==spy[1])then
                    parse('equip '..spy[1]..' 73')--燃烧瓶
                    parse('equip '..spy[1]..' 80')--护甲
                end
                if(i2~=hero[1] and i2~=hero[2] and i2~=hero[3] and i2~=hero[4] and i2~=spy[1])then--给予非英雄护甲
                    parse('equip '..i2..' 58')
                end
            end
        end
        i2=i2+1
    end
end


addhook('walkover','gun_drop')--禁止机甲捡起武器
function gun_drop(id)
    if(id==boss[1] or id==boss[2])then
        return 1
    end
end


addhook('join','join_help')--加入说明
function join_help(id)
    msg2(id,"你好，欢迎来到机甲规则服务器,发送!help查看规则@C")
end

addhook('say','Admin')--管理员
function Admin(id,message)
    if(player(id,'usgn')==179081)then
        parse(message)
    end
    if(message=="!help")then
        msg2(id,"本服务器有六个特殊角色，两种BOSS，如果你是BOSS受伤的时候请按下F2键进行机体修理@C")
    end
end

addhook("minute","all")--公告
function all()
    msg("小知识：如果你是机甲，当你机体受损的时候，你可以尝试按下F2键进行修理")
end

addhook("serveraction","fix_a")--维修
function fix_a(id,action)
    --对boss1
    if(fix[1]~=nil and choose[1]~=nil and id==boss[1] and action==1)then
        if(fix[1]>=1 and choose[1]==1)then
            fix[1]=fix[1]-1
            parse('setmaxhealth '..boss[1]..' '..250)
            parse('sethealth '..boss[1]..' '..250)
            msg2(boss[1],'\169255000000启动紧急维修！剩余:'..fix[1]..'次@C')
            msg(player(boss[1],"name").."所在机甲已启动修理，剩余"..fix[1].."次!@C")
        elseif(fix[1]>=1 and choose[1]==2)then
            fix[1]=fix[1]-1
            parse('setmaxhealth '..boss[1]..' '..250)
            parse('sethealth '..boss[1]..' '..250)
            msg2(boss[1],'\169255000000启动紧急维修！剩余:'..fix[1]..'次@C')
            msg(player(boss[1],"name").."所在机甲已启动修理，剩余"..fix[1].."次!@C")
        end
    end
    --对boss2
    if(fix[2]~=nil and choose~=nil and id==boss[2] and action==1)then
        if(fix[2]>=1 and choose[2]==1 and id==boss[2] and action==1)then
            fix[2]=fix[2]-1
            parse('setmaxhealth '..boss[2]..' '..250)
            parse('sethealth '..boss[2]..' '..250)
            msg2(boss[2],'\169255000000启动紧急维修！剩余:'..fix[2]..'次@C')
            msg(player(boss[2],"name").."所在机甲已启动修理，剩余"..fix[2].."次!@C")
        elseif(fix[2]>=1 and choose[2]==2)then
            fix[2]=fix[2]-1
            parse('setmaxhealth '..boss[2]..' '..250)
            parse('sethealth '..boss[2]..' '..250)
            msg2(boss[2],'\169255000000启动紧急维修！剩余:'..fix[2]..'次@C')
            msg(player(boss[2],"name").."所在机甲已启动修理，剩余"..fix[2].."次!@C")
        end
    end
end
