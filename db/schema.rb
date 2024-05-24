# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_05_24_194354) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "details", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "detalle"
    t.string "marca"
    t.string "modelo"
    t.string "n_serie"
    t.string "mm_marca"
    t.string "mm_n_serie"
    t.float "potencia"
    t.integer "capacidad"
    t.integer "personas"
    t.string "ct_marca"
    t.integer "ct_cantidad"
    t.float "ct_diametro"
    t.float "medidas_cintas"
    t.string "rv_marca"
    t.string "rv_n_serie"
    t.integer "paradas"
    t.integer "embarques"
    t.string "sala_maquinas"
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "velocidad"
    t.string "descripcion"
    t.string "rol_n"
    t.integer "numero_permiso"
    t.date "fecha_permiso"
    t.string "destino"
    t.string "recepcion"
    t.string "empresa_instaladora"
    t.string "empresa_instaladora_rut"
    t.integer "porcentaje"
    t.index ["item_id"], name: "index_details_on_item_id"
  end

  create_table "groups", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "name", null: false
    t.string "type"
    t.index ["deleted_at"], name: "index_groups_on_deleted_at"
    t.index ["name"], name: "index_groups_on_name", unique: true
    t.index ["number"], name: "index_groups_on_number", unique: true
  end

  create_table "inspections", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "number", null: false
    t.string "place", null: false
    t.date "ins_date", null: false
    t.date "inf_date"
    t.integer "validation"
    t.string "result", default: "Creado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state", default: "Abierto"
    t.bigint "user_id"
    t.bigint "item_id"
    t.bigint "principal_id", null: false
    t.index ["item_id"], name: "index_inspections_on_item_id"
    t.index ["number"], name: "index_inspections_on_number", unique: true
    t.index ["principal_id"], name: "index_inspections_on_principal_id"
    t.index ["user_id"], name: "index_inspections_on_user_id"
  end

  create_table "items", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "identificador", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "group_id", null: false
    t.bigint "principal_id", null: false
    t.index ["group_id"], name: "index_items_on_group_id"
    t.index ["identificador"], name: "index_items_on_identificador", unique: true
    t.index ["principal_id"], name: "index_items_on_principal_id"
  end

  create_table "ladder_details", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "marca"
    t.string "modelo"
    t.string "nserie"
    t.string "mm_marca"
    t.string "mm_nserie"
    t.float "potencia"
    t.integer "capacidad"
    t.integer "personas"
    t.integer "peldaños"
    t.float "longitud"
    t.integer "inclinacion"
    t.integer "ancho"
    t.float "velocidad"
    t.integer "fabricacion"
    t.string "procedencia"
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_ladder_details_on_item_id"
  end

  create_table "ladder_revisions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.text "codes"
    t.text "points"
    t.text "levels"
    t.text "fail"
    t.text "comment"
    t.text "number"
    t.text "priority"
    t.bigint "inspection_id", null: false
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "descripcion"
    t.string "rol_n"
    t.integer "numero_permiso"
    t.date "fecha_permiso"
    t.string "destino"
    t.string "recepcion"
    t.string "empresa_instaladora"
    t.string "empresa_instaladora_rut"
    t.integer "porcentaje"
    t.index ["inspection_id"], name: "index_ladder_revisions_on_inspection_id"
    t.index ["item_id"], name: "index_ladder_revisions_on_item_id"
  end

  create_table "ladders", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "number"
    t.text "point"
    t.string "code"
    t.string "priority"
    t.string "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "principals", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "rut", null: false
    t.string "name", null: false
    t.string "business_name", null: false
    t.string "contact_name"
    t.string "email", null: false
    t.string "phone"
    t.string "cellphone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_email"
    t.string "place"
  end

  create_table "reports", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "certificado_minvu"
    t.date "fecha"
    t.string "empresa_anterior"
    t.string "ea_rol"
    t.string "ea_rut"
    t.string "empresa_mantenedora"
    t.string "em_rol"
    t.string "em_rut"
    t.date "vi_co_man_ini"
    t.date "vi_co_man_ter"
    t.string "nom_tec_man"
    t.string "tm_rut"
    t.integer "ul_reg_man"
    t.date "urm_fecha"
    t.bigint "inspection_id", null: false
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cert_ant"
    t.date "ending"
    t.index ["inspection_id"], name: "index_reports_on_inspection_id"
    t.index ["item_id"], name: "index_reports_on_item_id"
  end

  create_table "revision_colors", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "number"
    t.boolean "color"
    t.string "revision_type", null: false
    t.bigint "revision_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["revision_type", "revision_id"], name: "index_revision_colors_on_revision"
  end

  create_table "revision_nulls", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.text "point"
    t.string "revision_type"
    t.bigint "revision_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["revision_type", "revision_id"], name: "index_revision_nulls_on_revision"
  end

  create_table "revision_photos", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "code"
    t.string "revision_type", null: false
    t.bigint "revision_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["revision_type", "revision_id"], name: "index_revision_photos_on_revision"
  end

  create_table "revisions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "inspection_id", null: false
    t.bigint "group_id", null: false
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "codes"
    t.text "points"
    t.text "levels"
    t.text "fail"
    t.text "comment"
    t.index ["group_id"], name: "index_revisions_on_group_id"
    t.index ["inspection_id"], name: "index_revisions_on_inspection_id"
    t.index ["item_id"], name: "index_revisions_on_item_id"
  end

  create_table "rules", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.text "point", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ruletype_id", null: false
    t.string "code"
    t.string "level"
    t.string "ins_type"
    t.index ["ruletype_id"], name: "index_rules_on_ruletype_id"
  end

  create_table "rulesets", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "rule_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_rulesets_on_group_id"
    t.index ["rule_id"], name: "index_rulesets_on_rule_id"
  end

  create_table "ruletypes", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.text "rtype"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gygatype", default: "", null: false
    t.string "gygatype_number"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "username", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "real_name", default: "", null: false
    t.string "email"
    t.string "profesion"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "details", "items"
  add_foreign_key "inspections", "items"
  add_foreign_key "inspections", "principals"
  add_foreign_key "inspections", "users"
  add_foreign_key "items", "groups"
  add_foreign_key "items", "principals"
  add_foreign_key "ladder_details", "items"
  add_foreign_key "ladder_revisions", "inspections"
  add_foreign_key "ladder_revisions", "items"
  add_foreign_key "reports", "inspections"
  add_foreign_key "reports", "items"
  add_foreign_key "revisions", "groups"
  add_foreign_key "revisions", "inspections"
  add_foreign_key "revisions", "items"
  add_foreign_key "rules", "ruletypes"
  add_foreign_key "rulesets", "groups"
  add_foreign_key "rulesets", "rules"
end
