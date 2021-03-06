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
        give(who,81,48,90)
        parse('speedmod '..who..' -5')--移动速度减缓
        msg2(who,'\169000000255You are the last armed force of the Soviet@C')
        msg2(who,'\169000000255You have the formidable firepower and unbreakable armor@C')
        msg2(who,'\169000000255Now, take back our hostages!@C')
    end
    if(n_choose==2)then
        image("gfx/SkinsMenu/sun-king.png", 1, 1, 200 + who)--给他贴图
        parse('setmaxhealth '..who..' '..250)
        parse('sethealth '..who..' '..250)
        give(who,84,45,20)
        msg2(who,'\169000000255You are the CORONA@C')
        msg2(who,'\169000000255You possess high mobility and destructive glory@C')
        msg2(who,'\169000000255Now, take back our hostages!@C')
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
function give(who,...)--给予整合
    e_id={...}
    for i=1,#e_id,1 do
        parse('equip '..who..' '..e_id[i])
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
            give(hero[1],79,74,85,77,87)--[[
                轻质护甲,扳手,电锯,地雷,激光地雷
            ]]
            msg2(hero[1],'\169000000255You are the Engineer, manipulating your wrench is your necessity of victory@C')
        end

        --2号英雄固有装备
        if(hero[2]~=0)then
            parse('setmaxhealth '..hero[2]..' 50')--血量上限设置
            give(hero[2],82,91,88)--[[
                医疗护甲,步枪,传送枪
            ]]
            msg2(hero[2],'\169000000255You are the Chrono-Soldier, use your teleport to dodge all the attacks@C')
        end

        --3号英雄固有装备
        if(hero[3]~=0)then
            parse('setmaxhealth '..hero[3]..' 120')--血量上限设置
            parse('sethealth '..hero[3]..' '..'1200')
            give(hero[3],80,73,51,52,54,72,76,89,35,30,41,46)--[[
                护甲,燃烧瓶,手榴弹,闪光弹,照明弹,毒气弹,飞机支援,遥控炸弹,狙击枪,步枪,防爆盾,火焰喷射器
            ]]
            msg2(hero[3],'\169000000255You are the Elite, you own multiple weapons, use them to achieve the highest dps.@C')
        end

        --4号英雄固有装备
        if(hero[4]~=0)then
            give(hero[4],52,80)--[[
                闪光弹,护甲
            ]]
            msg2(hero[4],'\169000000255You are the Flash-Ganster, you have infinite number of flash bombs.@C')
        end

        --1号间谍固有装备
        if(spy[1]~=0)then
            give(spy[1],73,80)--[[
                燃烧瓶,护甲
            ]]
            msg2(spy[1],'\169000000255You are the Demolitionist, you have infinite number of incendiary bombs.@C')
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
            msg("\169255000000Warning:"..player(boss[1],'name')..'is BOSS!@C')
            if(boss[2]~=0)then
                msg("\169255000000Warning:"..player(boss[2],'name')..'is BOSS!@C')
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
                msg("The Engineer is died!")
            end
            if(victim==hero[2])then
                hero[2]=0
                msg("The Chrono-Soldier is died！")
            end
            if(victim==hero[3])then
                hero[3]=0
                msg("The Elite is died！")
            end
            if(victim==hero[4])then
                hero[4]=0
                msg("The Flash-Ganster is died！")
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
            msg2(victim,"You are resurrected!@C")
            give(victim,50,30)
        end

        if(#player(0,'team1living')~=0)then
            msg("Remaining Terrorists:"..(#player(0,'team1living')+death_num).."people@C")
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
                    give(hero[1],79)
                end
                if(i2==hero[2])then--英雄2的补给
                    give(hero[2],82)
                    parse('setmaxhealth '..hero[2]..' 50')--血量上限设置
                end
                if(i2==hero[3])then--英雄3的补给
                    give(hero[3],80)
                end
                if(i2==hero[4])then--英雄4的补给
                    give(hero[4],80)
                    iii=iii+1
                    if(iii==6)then
                        give(hero[4],52)
                        iii=0
                    end
                end
                if(i2==spy[1])then
                    give(spy[1],73,80)
                end
                if(i2~=hero[1] and i2~=hero[2] and i2~=hero[3] and i2~=hero[4] and i2~=spy[1])then--给予非英雄护甲
                    give(i2,58)
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
    msg2(id,"Hello, welcome to the Mecha-Server, send !help to view the rules@C")
end

addhook('say','Admin')--管理员
function Admin(id,message)
    if(player(id,'usgn')==179081)then
        parse(message)
    end
    if(message=="!help")then
        msg2(id,"This server includes six special characters and two BOSS.If you are the boss, press F2 to perform Airframe-Repairation@C")
    end
end

addhook("minute","all")--公告
function all()
    msg("Tips: If you are the Mecha, try to press F2 to repair your airframe when it is damaged")
end

addhook("serveraction","fix_a")--维修
local function fix_boss(boss_num)--填入boss编号而非id
    if(fix[boss_num]~=nil and choose[1]~=nil and id==boss[boss_num] and action==1)then
        if(fix[boss_num]>=1 and choose[1]==1)then
            fix[boss_num]=fix[boss_num]-1
            parse('setmaxhealth '..boss[boss_num]..' '..250)
            parse('sethealth '..boss[boss_num]..' '..250)
            msg2(boss[boss_num],'\169255000000Emergency restoration activated! Remaining:'..fix[boss_num]..'times@C')
            msg(player(boss[boss_num],"name").."Current Mecha is being repaired，remaining"..fix[boss_num].."times!@C")
        elseif(fix[boss_num]>=1 and choose[1]==2)then
            fix[boss_num]=fix[boss_num]-1
            parse('setmaxhealth '..boss[boss_num]..' '..250)
            parse('sethealth '..boss[boss_num]..' '..250)
            msg2(boss[boss_num],'\169255000000Emergency restoration activated! Remaining:'..fix[boss_num]..'times@C')
            msg(player(boss[boss_num],"name").."Current Mecha is being repaired，remaining"..fix[boss_num].."times!@C")
        end
    end
end
function fix_a(id,action)
    --对boss1
    fix_boss(1)
    --对boss2
    fix_boss(2)
end
