local function kcv_rank_up(card)
    local suit_prefix = string.sub(card.base.suit, 1, 1) .. '_'
    local rank_suffix = card.base.id == 14 and 2 or math.min(card.base.id + 1, 14)
    if rank_suffix < 10 then
        rank_suffix = tostring(rank_suffix)
    elseif rank_suffix == 10 then
        rank_suffix = 'T'
    elseif rank_suffix == 11 then
        rank_suffix = 'J'
    elseif rank_suffix == 12 then
        rank_suffix = 'Q'
    elseif rank_suffix == 13 then
        rank_suffix = 'K'
    elseif rank_suffix == 14 then
        rank_suffix = 'A'
    end
    card.kcv_ignore_debuff_check = true
    card.kcv_dont_update_sprites = true
    card:set_base(G.P_CARDS[suit_prefix .. rank_suffix])
end

SMODS.Joker {
    key = "5day",
    name = "Five-Day Forecast",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('5day')
    },
    rarity = 2,
    cost = 8,
    unlocked = true,
    discovered = true,
    eternal_compat = false,
    perishable_compat = true,
    blueprint_compat = true,
    config = {},
    loc_txt = {
        name = "五日天气预报",
        text = {"如果打出的牌中包含{C:attention}顺子",
                "则将其中所有牌的点数提升{C:attention}1",
                "{C:inactive}（不含{C:attention}A{C:inactive}）"}
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {}
        }
    end,
    calculate = function(self, card, context)
        if context.kcv_forecast_event then
            if next(context.poker_hands["Straight"]) then
                for i, other_c in ipairs(context.scoring_hand) do
                    if other_c:get_id() ~= 14 then
                        kcv_rank_up(other_c)
                    end
                end
            end
        end
        if context.before then
            if next(context.poker_hands["Straight"]) then
                local targets = {}
                for i, other_c in ipairs(context.scoring_hand) do
                    if other_c:get_id() ~= 14 then
                        table.insert(targets, other_c)
                    end
                end

                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = localize('k_active_ex'),
                    colour = G.C.FILTER
                });

                for i_2, other_c_2 in ipairs(targets) do
                    local percent = 1.15 - (i_2 - 0.999) / (#G.hand.cards - 0.998) * 0.3
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('card1', percent)
                            other_c_2:flip()
                            return true
                        end
                    }))
                    delay(0.15)
                end
                delay(0.3)
                for i_3, other_c_3 in ipairs(targets) do
                    local percent = 0.85 + (i_3 - 0.999) / (#G.hand.cards - 0.998) * 0.3
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            -- update sprites that were postponed by kcv_dont_update_sprites
                            other_c_3:set_sprites(other_c_3.config.center, other_c_3)
                            other_c_3.kcv_dont_update_sprites = nil
                            other_c_3.kcv_ignore_debuff_check = nil
                            play_sound('tarot2', percent, 0.6)
                            other_c_3:flip()
                            return true
                        end
                    }))
                    delay(0.15)
                end
            end
        end
    end
}
